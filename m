From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv6: remove redundant RTM_DELLINK message
Date: Sat, 15 Sep 2007 21:48:49 -0700 (PDT)
Message-ID: <20070915.214849.116360376.davem@davemloft.net>
References: <20070912145030.GA29748@wq.cz>
	<20070912145323.GE18480@postel.suug.ch>
	<20070913095738.GA4168@wq.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: milon@wq.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:34098
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750770AbXIPEsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 00:48:55 -0400
In-Reply-To: <20070913095738.GA4168@wq.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Milan Kocian <milon@wq.cz>
Date: Thu, 13 Sep 2007 11:57:38 +0200

> remove useless message. We get right message from other subsystem.
 ...
> Signed-off-by: Milan Kocian <milon@wq.cz>

Applied, thanks Milan.
