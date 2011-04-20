From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] net: r8169: convert to hw_features
Date: Wed, 20 Apr 2011 21:13:36 +0200
Message-ID: <20110420191336.GB18805@electric-eye.fr.zoreil.com>
References: <20110413174758.GA17579@electric-eye.fr.zoreil.com> <1302718764.3167.7.camel@lap75545.ornl.gov> <20110418180857.GB18469@electric-eye.fr.zoreil.com> <20110418.225400.189709717.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dave@thedillows.org, netdev@vger.kernel.org, nic_swsd@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52426 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755641Ab1DTTXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 15:23:10 -0400
Content-Disposition: inline
In-Reply-To: <20110418.225400.189709717.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> Francois, since TSO is disabled by default I'm applying this to
> net-next-2.6, thanks!

Fine.

> Maybe we can progressively start to try and turn these things on
> by default now that we know more about the TX descriptor layout
> differences.

Sure. I'd welcome a little timeslot to push a few configuration and
cosmetic things though.

-- 
Ueimor
