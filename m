From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2.6.18] WE-21 support (core API)
Date: Mon, 04 Sep 2006 10:17:16 +0200
Message-ID: <1157357836.3324.28.camel@ux156>
References: <20060830005655.GA8405@bougret.hpl.hp.com>
	 <200609012055.48799.mb@bu3sch.de>
	 <20060901221045.GB13975@bougret.hpl.hp.com>
	 <200609020247.14755.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:13540 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932497AbWIDIQl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 04:16:41 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609020247.14755.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-09-02 at 02:47 +0200, Michael Buesch wrote:

> And we don't need all this stuff on these devices? OK, nl80211
> can easily be made optional, too.

Not the whole of nl80211, but I guess some parts for event reporting
etc. could be made optional and the functions tiny do-nothing inlines.

johannes

-- 
VGER BF report: U 0.510304
