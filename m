From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH][BLUETOOTH] remove now unneeded references to
	sk_protinfo
Date: Sat, 19 Mar 2005 19:28:48 +0100
Message-ID: <1111256928.9930.1.camel@pegasus>
References: <20050319180603.GB29585@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Network Development Mailing List <netdev@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20050319180603.GB29585@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Arnaldo,

> 	Please apply this patch, now only the HAM radio protocols
> and af_wanpipe uses sk_protinfo.
> 
> 	Available at:
> 
> bk://kernel.bkbits.net/acme/connection_sock-2.6

patch is in my tree now and I will send it to Dave with fixes for some
other race conditions very soon. One of them needs some extra testing.

Regards

Marcel
