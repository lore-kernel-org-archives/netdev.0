From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH] wavelan: fix section mismatch
Date: Thu, 25 May 2006 12:00:28 -0700
Message-ID: <20060525120028.e9004ea7.rdunlap@xenotime.net>
References: <20060525110921.afaa98ce.rdunlap@xenotime.net>
	<20060525183949.GA23930@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:7346 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1030346AbWEYS54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 14:57:56 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 25 May 2006 11:57:52 -0700
To: jt@hpl.hp.com
In-Reply-To: <20060525183949.GA23930@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 May 2006 11:39:49 -0700 Jean Tourrilhes wrote:

> On Thu, May 25, 2006 at 11:09:21AM -0700, Randy.Dunlap wrote:
> > From: Randy Dunlap <rdunlap@xenotime.net>
> > 
> > Fix section mismatch warning:
> > WARNING: drivers/net/wireless/wavelan.o - Section mismatch: reference to
> > .init.text: from .text between 'init_module' (at offset 0x371e) and
> > 'cleanup_module'
> > 
> > Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
> 
> 	I did not check that kernel, but it seems a no brainer. Would
> you mind sending to John Linville or Jeff Garzik as I'm about to go on
> vacvation.
> 	Thanks !
> 
> 	Jean

Hi, John L. was copied on the patch.

Thanks, have a nice vacation.

---
~Randy
