From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Loop detected - calling function from different modules
Date: Mon, 04 Sep 2006 09:07:39 +0200
Message-ID: <1157353660.3324.4.camel@ux156>
References: <BAY101-F393A459AE607C79C6EE299AB320@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, madwifi-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:33730 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932400AbWIDHHD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 03:07:03 -0400
To: Frank Schneider <twodipu@hotmail.com>
In-Reply-To: <BAY101-F393A459AE607C79C6EE299AB320@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frank,

> could anyone please give me a hints how  dev_queue_xmit() is using tx data 
> queue (HAL_TX_QUEUE_DATA) to transmit data queue.
> actually I want to use data queue for sending beacon frame, ofcourse not 
> real implementation
> but for an experiment, a research purpose..

It's probably *far* easier for you to buy a Broadcom wireless card and
use it with bcm43xx-d80211.

I can't help you more with ath stuff, nor with your programming model
which is fundamentally broken.

johannes

-- 
VGER BF report: U 0.83072
