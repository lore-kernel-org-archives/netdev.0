From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: FIX
Date: Tue, 27 Jan 2004 00:57:38 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040127025737.GG28005@conectiva.com.br>
References: <20040124131307.GB2666@bender.home.hensema.net> <20040126.123042.104046496.davem@redhat.com> <20040127.070142.93371828.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, erik@hensema.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040127.070142.93371828.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Tue, Jan 27, 2004 at 07:01:42AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ escreveu:
> In article <20040126.123042.104046496.davem@redhat.com> (at Mon, 26 Jan 2004 12:30:42 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:
> 
> > 
> > Ok, I've figured out the bug.  Arnaldo only fixed one of the
> > two incorrect calls to sk_add_node() which should both be
> > __sk_add_node().
> 
> Thanks you!

Great! Thanks!

- Arnaldo
