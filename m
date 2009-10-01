From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] net: fix NOHZ: local_softirq_pending 08
Date: Thu, 1 Oct 2009 16:04:40 +0200
Message-ID: <200910011604.42916.mb@bu3sch.de>
References: <1254324077.3959.7.camel@johannes.local> <4AC3A0F1.3060306@hartkopp.net> <20090930.163333.234658158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: oliver@hartkopp.net, johannes@sipsolutions.net, kalle.valo@iki.fi,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:46892 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932232AbZJAOEo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 10:04:44 -0400
In-Reply-To: <20090930.163333.234658158.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 01 October 2009 01:33:33 David Miller wrote:

> I'm not applying this until all of these details are sorted out 

John, please apply my fix to wireless-testing to get rid of the regression.
You can revert it later, if there's a better fix available.

-- 
Greetings, Michael.
