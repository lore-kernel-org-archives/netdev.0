From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: oops in tcp_v4_rcv.
Date: Wed, 28 May 2003 23:00:35 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529020034.GT12434@conectiva.com.br>
References: <3ED55F4D.1070306@colorfullife.com> <20030528.184054.78710412.davem@redhat.com> <20030529015020.GS12434@conectiva.com.br> <20030528.185142.85410989.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: manfred@colorfullife.com, netdev@oss.sgi.com, akpm@digeo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030528.185142.85410989.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, May 28, 2003 at 06:51:42PM -0700, David S. Miller escreveu:
>    From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
>    Date: Wed, 28 May 2003 22:50:20 -0300
> 
>    Em Wed, May 28, 2003 at 06:40:54PM -0700, David S. Miller escreveu:
>    > I'll try to fix this.
>    
>    I'm as well looking at this, longstanding bug :-\
> 
> Here's a patch, should work:

At first look, agreed. Thanks David for fixing this.

- Arnaldo
