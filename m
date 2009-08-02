From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 4/5] be2net: some name changes for
 consistency
Date: Sat, 01 Aug 2009 23:08:02 -0700 (PDT)
Message-ID: <20090801.230802.186396893.davem@davemloft.net>
References: <20090728085310.GA5009@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41257
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751820AbZHBGHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 02:07:53 -0400
In-Reply-To: <20090728085310.GA5009@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Tue, 28 Jul 2009 14:23:10 +0530

> be_mbox_db_ring() has been changed to be_mbox_notify() (to be consistent with
> be_mcc_notify()) and struct be_mcc_cq_entry changed to be_mcc_compl
> to be consistent with rx/tx_compl.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
