From: Olaf Hering <olh@suse.de>
Subject: Re: comment about struct tcp_tw_bucket in struct sock
Date: Wed, 14 May 2003 10:00:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030514080043.GA2575@suse.de>
References: <20030513210541.GA4415@suse.de> <20030513.163150.28800008.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: marcelo@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030513.163150.28800008.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 On Tue, May 13, David S. Miller wrote:

>    From: Olaf Hering <olh@suse.de>
>    Date: Tue, 13 May 2003 23:05:41 +0200
> 
>    we just hit this one. struct tcp_tw_bucket and stuct sock must match.
>    
>    Please apply.
> 
> It's documented in tcp.h already.

True, but not in struct sock.


-- 
USB is for mice, FireWire is for men!
