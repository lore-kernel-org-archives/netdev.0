From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] net: filter: Just In Time compiler for sparc
Date: Thu, 19 Apr 2012 17:29:37 +0200
Message-ID: <20120419152937.GA1120@merkur.ravnborg.org>
References: <20120416.225823.1395194623649559124.davem@davemloft.net> <20120417195716.GA26750@merkur.ravnborg.org> <20120417.164400.89608576188768018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120417.164400.89608576188768018.davem@davemloft.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> >> +	select HAVE_BPF_JIT
> > If we sorted this block of select then the chances
> > for merge conflict would be smaller.
> > But this is not this patch to do so.
> 
> I also think we should create an arch/sparc/Kbuild for sparc
> too, just like x86 has.

I will look into both issues.
But only after the merge window to avoid conflicts.

	Sam
