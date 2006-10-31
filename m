From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: sky2 hang.
Date: Tue, 31 Oct 2006 10:33:32 +0300
Message-ID: <20061031073332.GA20607@2ka.mipt.ru>
References: <20061031061144.GA1562@2ka.mipt.ru> <4546EC12.1060808@osdl.org> <20061031070405.GA19344@2ka.mipt.ru> <20061031070812.GK15787@ned.snow-crash.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:36822 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1161413AbWJaHdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 02:33:31 -0500
To: Alexander Wirt <formorer@debian.org>
Content-Disposition: inline
In-Reply-To: <20061031070812.GK15787@ned.snow-crash.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 31, 2006 at 08:08:12AM +0100, Alexander Wirt (formorer@debian.org) wrote:
> > > Run 2.6.19-rc3 or 2.6.18.2 or dig out the patch from last week.
> > 
> > Thanks.
> > I hope debian maintainers will rebase it's tree eventually.
> Then please take sure that there is a bug report describing 
> ther problem (maybe with a patch?).
> 
> Alex
> 
> P.S. No I don't have anything to do with the kernel team :). 
 
I've created one using reportbug (even not created, but provided as
additional info to some other bug), hope it is correct.
It's number is 396185.

P.S. IMHO Debian bug reporting tool is the most unconvenient thing in 
the whole distro :)

-- 
	Evgeniy Polyakov
