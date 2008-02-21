From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2008-02-20
Date: Wed, 20 Feb 2008 22:15:10 -0800 (PST)
Message-ID: <20080220.221510.28377813.davem@davemloft.net>
References: <20080221021132.GF3825@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52352
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752414AbYBUGOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 01:14:33 -0500
In-Reply-To: <20080221021132.GF3825@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 20 Feb 2008 21:11:32 -0500

>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Pulled and pushed back out, thanks John.

>       ssb: Fix the GPIO API

This could have had a much better changelog, it's way too terse.

For example, what was so unusable about the interface beforehand that
absolutely requires it be changed in order to subsequently fix bugs?

The changelog doesn't go into any detail at all.

Thanks.
