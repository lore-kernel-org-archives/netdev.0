From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: question about linux tcp request queue handling
Date: Sun, 06 Jul 2003 22:59:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F090C28.4080405@us.ibm.com>
References: <3F08858E.8000907@us.ibm.com> <001a01c3441c$6fe111a0$6801a8c0@oemcomputer> <3F08B7E2.7040208@us.ibm.com> <000d01c3444f$e6439600$6801a8c0@oemcomputer> <3F090A4F.10004@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Albrecht <palbrecht@qwest.net>, linux-kernel@vger.kernel.org,
   netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <3F090A4F.10004@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita Singhvi wrote:

> Er, complete the 3 way handshake? If the client gets the syn/ack, it
> should send a SYN in response, and move to ESTABLISHED state. If the
		~~~

my bad, sorry, that should be ACK, of course...

thanks,
Nivedita
