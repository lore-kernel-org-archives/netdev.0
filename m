From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: comment about struct tcp_tw_bucket in struct sock
Date: Tue, 13 May 2003 23:44:56 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030514024456.GE28128@conectiva.com.br>
References: <20030513210541.GA4415@suse.de> <20030513.163150.28800008.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: olh@suse.de, marcelo@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030513.163150.28800008.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Tue, May 13, 2003 at 04:31:50PM -0700, David S. Miller escreveu:
>    From: Olaf Hering <olh@suse.de>
>    Date: Tue, 13 May 2003 23:05:41 +0200
> 
>    we just hit this one. struct tcp_tw_bucket and stuct sock must match.
>    
>    Please apply.
> 
> It's documented in tcp.h already.

Yes, and in 2.5 the situation is a bit better, I still have an itching to
revisit this at some point, together with struct open_request, etc 8)

- Arnaldo
