From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [Infrahip] [PATCH] Host Identity Protocol
Date: Mon, 21 Mar 2005 02:42:41 +0900 (JST)
Message-ID: <20050321.024241.67451836.yoshfuji@linux-ipv6.org>
References: <42369919.9010203@cs.helsinki.fi>
	<Pine.GSO.4.58.0503201805240.1521@kekkonen.cs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gurtov@cs.helsinki.fi, netdev@oss.sgi.com, infrahip@hiit.fi,
        yoshfuji@linux-ipv6.org
To: miika@iki.fi
In-Reply-To: <Pine.GSO.4.58.0503201805240.1521@kekkonen.cs.hut.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.GSO.4.58.0503201805240.1521@kekkonen.cs.hut.fi> (at Sun, 20 Mar 2005 18:08:30 +0200 (EET)), Miika Komu <miika@iki.fi> says:

> On Tue, 15 Mar 2005, Andrei Gurtov wrote:
> 
> > Please have a look at Host Identity Protocol, a better solution for
> > secure mobility and multihoming than Mobile IP.
:
> I made the release directory structure more usable. The latest patch can
> be found from:
> 
> http://infrahip.hiit.fi/hipl/release/0.1.2/linux-2.6.10-hipl-0.1.2.patch

I think you're doing great work.
However, all signaling should be handled in userspace as we (will) do for MIP6.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
