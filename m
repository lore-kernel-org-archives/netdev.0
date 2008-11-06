From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH] SSB: make it depend on PCI
Date: Thu, 6 Nov 2008 16:14:30 -0500
Message-ID: <8bd0f97a0811061314x53e871c8rc9a7de4c4c10f359@mail.gmail.com>
References: <1225965082-31462-1-git-send-email-vapier@gentoo.org>
	 <1225970982.3619.211.camel@johannes.berg>
	 <8bd0f97a0811060332k281ae4d1m1fee62b27d811037@mail.gmail.com>
	 <200811061759.29319.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Johannes Berg" <johannes@sipsolutions.net>,
	"Mike Frysinger" <vapier@gentoo.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:33157 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932AbYKFVOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 16:14:31 -0500
In-Reply-To: <200811061759.29319.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 6, 2008 at 11:59, Michael Buesch wrote:
> On Thursday 06 November 2008 12:32:50 Mike Frysinger wrote:
>> OK.  regarding the patch, if we drop the "&& PCI" part, i think the
>> rest should get merged ... having empty menus in kconfig is annoying.
>> agreed ?
>
> We have these all over the place.

that's a weak argument.  empty menus should go away, not remain
"because other people are doing it too".  with that mentality, there's
many issues we wouldnt be able to address.
-mike
