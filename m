From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: BUG in bcm32xx-d80211: sleeping function called with irq's
	disabled
Date: Mon, 04 Sep 2006 09:10:54 +0200
Message-ID: <1157353854.3324.9.camel@ux156>
References: <44FA4F42.1020302@lwfinger.net>
	 <200609031449.16702.mb@bu3sch.de>  <44FAF50C.9050905@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	linville@tuxdriver.com, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:62658 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932408AbWIDHKT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 03:10:19 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44FAF50C.9050905@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-09-03 at 10:30 -0500, Larry Finger wrote:

> The patch fixes the problem on my machine. Should I add my name to the signed-off-by list?

put Acked-by, you didn't write any of the code and are not passing it on
in this case so you don't need to sign it off I guess :)

johannes

-- 
VGER BF report: U 0.644788
