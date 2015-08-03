From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Permit users to change transmit and receive max
 pachet size
Date: Mon, 03 Aug 2015 14:56:08 -0700 (PDT)
Message-ID: <20150803.145608.1565215068703069235.davem@davemloft.net>
References: <ctml34x6j21mkn1wutfemkq7.1438638110313@email.android.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: corcodel.marian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45093 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932332AbbHCV4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 17:56:11 -0400
In-Reply-To: <ctml34x6j21mkn1wutfemkq7.1438638110313@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Corcodel.marian" <corcodel.marian@gmail.com>
Date: Tue, 04 Aug 2015 00:41:50 +0300

> A this moment these param is only for test and not for large utilization.

Then you can patch your local driver for "testing".

You change doesn't belong upstream.  We're not going to litter drivers
with debugging hack options.
