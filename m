From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: An issue on one network development.
Date: Fri, 20 Aug 2004 20:35:42 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040820233542.GI24215@conectiva.com.br>
References: <41263245.8050305@rus.uni-stuttgart.de> <20040820233251.GH24215@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Zhikui Chen <zhikui.chen@rus.uni-stuttgart.de>
Content-Disposition: inline
In-Reply-To: <20040820233251.GH24215@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Fri, Aug 20, 2004 at 08:32:52PM -0300, Arnaldo Carvalho de Melo escreveu:
> Em Fri, Aug 20, 2004 at 07:17:57PM +0200, Zhikui Chen escreveu:
> > Dear all,
> > 
> > HELP!
> > 
> > I am writing a DCCP code in Linux kernel 2.6.6,  I met a problem, which 
> > bored me about two weeks. Hope you to give me some hints, thanks in 
> > advance. The problem is on structure sock in dccp_lookup_listen of 
> > dccp_lookup.
> 
> We should talk then, I'm doing the same 8)
>  
> I'll take a look at what you have if you point me to the right direction,
> my code is at bk://kernel.bkbits.net/acme/dccp-2.6, but is still in the
> TCPfication skeleton right now.

Ah, I started this from the work done by Patrick McManus, but now I'm
mostly rewriting it, this weekend I'll get back to it, I hope 8)

- Arnaldo
