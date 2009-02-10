From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>
Subject: Re: [PATCH] net/sunrpc/xprtsock.c: some common code found
Date: Tue, 10 Feb 2009 15:20:36 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902101514540.31742@wrl-59.cs.helsinki.fi>
References: <20090206.140714.201930500.davem@davemloft.net>
 <CAF18546-B024-40C9-8276-8FCD89C98E72@oracle.com>
 <Pine.LNX.4.64.0902070040530.31875@wrl-59.cs.helsinki.fi>
 <20090206.192243.47948705.davem@davemloft.net> <1234023804.17241.14.camel@heimdal.trondhjem.org>
 <Pine.LNX.4.64.0902071831210.2805@wrl-59.cs.helsinki.fi>
 <20090208052543.GA20689@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, trond-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090208052543.GA20689-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 8 Feb 2009, J. Bruce Fields wrote:

> (Where's diff-func from?)

My own tool collection. I can make it available if you want to.

> In similar cases in the future, if you want to cater to the more tired
> and/or mentally challenged among us (which may just be me), some clue
> that visually distinguishes the quoted diff output in the comment might
> help; e.g., maybe indent it like the below.
> 
> (But that's intended as a suggestion, not a requirement.)

Yeah, a good idea... I'll sed some spaces in front of them in the future 
to make the difference more obvious. The expected outcome though is that 
somebody probably then hits reply button too soon claiming that the patch 
is broken :-).


-- 
 i.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
