From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 11/13] net/socket.c::__sock_create() cleanup.
Date: Wed, 24 Nov 2004 00:29:00 -0800
Message-ID: <20041124002900.27641878.davem@davemloft.net>
References: <200411220644.iAM6i9900678@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        lcapitulino@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200411220644.iAM6i9900678@mail.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 21 Nov 2004 22:43:57 -0800
akpm@osdl.org wrote:

> 
> From: "Luiz Fernando N. Capitulino" <lcapitulino@conectiva.com.br>
> 
> The 'i' variable in net/socket.c::__sock_create() is not necessary.  It's
> have been used to store error codes but there is an 'err' variable already.
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@conectiva.com.br>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Looks good, queued for 2.6.11
