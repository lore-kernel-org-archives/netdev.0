From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH]: bcm43xx-d80211: fix hwcrypto issues (mcast)
Date: Fri, 17 Nov 2006 08:53:50 +0100
Message-ID: <1163750030.4047.1.camel@ux156>
References: <ej09qf$2nv$1@sea.gmane.org> <200611120934.28133.mb@bu3sch.de>
	 <20061114142959.GA17486@keitarou>  <200611161507.33971.mb@bu3sch.de>
	 <1163749589.5826.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Paul TBBle Hampson <Paul.Hampson@pobox.com>,
	linville@tuxdriver.com, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:24216 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1162420AbWKQHwp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 02:52:45 -0500
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1163749589.5826.5.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-11-17 at 18:46 +1100, Benjamin Herrenschmidt wrote:

> So what is the solution for Apple machines owner who only get a v3
> firmware from Apple ? I remember you telling me the answer on irc but I
> wanted to make it public :-) Some web site we can d/l the windows
> updates and extract the FW ?

Yes, fwcutter comes with a huge list of URLs for both firmware versions
(I suppose they'll remove the v3 ones now...)

Also, very new Apple drivers (AppleAirportExpress4311 or something like
that) for the PCI-E stuff contains v4 firmware, but I doubt you'd get
those drivers with an update.

johannes
