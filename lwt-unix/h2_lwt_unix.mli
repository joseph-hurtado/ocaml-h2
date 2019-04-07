(*----------------------------------------------------------------------------
 *  Copyright (c) 2019 António Nuno Monteiro
 *
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice,
 *  this list of conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the distribution.
 *
 *  3. Neither the name of the copyright holder nor the names of its
 *  contributors may be used to endorse or promote products derived from this
 *  software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 *  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *  POSSIBILITY OF SUCH DAMAGE.
 *---------------------------------------------------------------------------*)

open H2

(* The function that results from [create_connection_handler] should be passed
   to [Lwt_io.establish_server_with_client_socket]. *)
module Server : sig
  val create_connection_handler
    :  ?config:Config.t
    -> request_handler:(Unix.sockaddr -> Server_connection.request_handler)
    -> error_handler:(Unix.sockaddr -> Server_connection.error_handler)
    -> Unix.sockaddr
    -> Lwt_unix.file_descr
    -> unit Lwt.t

  module TLS : sig
    val create_connection_handler
      :  ?server:Tls_io.server
      -> ?certfile:string
      -> ?keyfile:string
      -> ?config:Config.t
      -> request_handler:(Unix.sockaddr -> Server_connection.request_handler)
      -> error_handler:(Unix.sockaddr -> Server_connection.error_handler)
      -> Unix.sockaddr
      -> Lwt_unix.file_descr
      -> unit Lwt.t
  end

  module SSL : sig
    val create_connection_handler
      :  ?server:Ssl_io.server
      -> ?certfile:string
      -> ?keyfile:string
      -> ?config:Config.t
      -> request_handler:(Unix.sockaddr -> Server_connection.request_handler)
      -> error_handler:(Unix.sockaddr -> Server_connection.error_handler)
      -> Unix.sockaddr
      -> Lwt_unix.file_descr
      -> unit Lwt.t
  end
end

module Client : sig
  type t

  val create_connection
    :  ?config:Config.t
    -> ?push_handler:(Request.t
                      -> (Client_connection.response_handler, unit) result)
    -> error_handler:Client_connection.error_handler
    -> Lwt_unix.file_descr
    -> t Lwt.t

  val request
    :  t
    -> Request.t
    -> error_handler:Client_connection.error_handler
    -> response_handler:Client_connection.response_handler
    -> [ `write ] Body.t

  val ping : t -> ?payload:Bigstringaf.t -> ?off:int -> (unit -> unit) -> unit

  val shutdown : t -> unit

  module TLS : sig
    type t

    val create_connection
      :  ?client:Tls_io.client
      -> ?config:Config.t
      -> ?push_handler:(Request.t
                        -> (Client_connection.response_handler, unit) result)
      -> error_handler:Client_connection.error_handler
      -> Lwt_unix.file_descr
      -> t Lwt.t

    val request
      :  t
      -> Request.t
      -> error_handler:Client_connection.error_handler
      -> response_handler:Client_connection.response_handler
      -> [ `write ] Body.t

    val ping
      :  t
      -> ?payload:Bigstringaf.t
      -> ?off:int
      -> (unit -> unit)
      -> unit

    val shutdown : t -> unit
  end

  module SSL : sig
    type t

    val create_connection
      :  ?client:Ssl_io.client
      -> ?config:Config.t
      -> ?push_handler:(Request.t
                        -> (Client_connection.response_handler, unit) result)
      -> error_handler:Client_connection.error_handler
      -> Lwt_unix.file_descr
      -> t Lwt.t

    val request
      :  t
      -> Request.t
      -> error_handler:Client_connection.error_handler
      -> response_handler:Client_connection.response_handler
      -> [ `write ] Body.t

    val ping
      :  t
      -> ?payload:Bigstringaf.t
      -> ?off:int
      -> (unit -> unit)
      -> unit

    val shutdown : t -> unit
  end
end