From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] SSB: make it depend on PCI
Date: Thu, 6 Nov 2008 22:24:26 +0100
Message-ID: <200811062224.26698.mb@bu3sch.de>
References: <1225965082-31462-1-git-send-email-vapier@gentoo.org> <200811061759.29319.mb@bu3sch.de> <8bd0f97a0811061314x53e871c8rc9a7de4c4c10f359@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Johannes Berg" <johannes@sipsolutions.net>,
	"Mike Frysinger" <vapier@gentoo.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Mike Frysinger" <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:37967 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750978AbYKFVYv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 16:24:51 -0500
In-Reply-To: <8bd0f97a0811061314x53e871c8rc9a7de4c4c10f359@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 06 November 2008 22:14:30 Mike Frysinger wrote:
> On Thu, Nov 6, 2008 at 11:59, Michael Buesch wrote:
> > On Thursday 06 November 2008 12:32:50 Mike Frysinger wrote:
> >> OK.  regarding the patch, if we drop the "&& PCI" part, i think the
> >> rest should get merged ... having empty menus in kconfig is annoying.
> >> agreed ?
> >
> > We have these all over the place.
> 
> that's a weak argument.  empty menus should go away, not remain
> "because other people are doing it too".  with that mentality, there's
> many issues we wouldnt be able to address.

Well, I don't see this as an issue, as 99.9% of the people don't hit that
case and if they do it doesn't matter anyway.
But hey, if you want to apply this, feel free to do so.

-- 
Greetings Michael.
