From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Minor extensions to marvell phy driver
Date: Mon, 02 Aug 2010 22:09:45 -0700 (PDT)
Message-ID: <20100802.220945.212413185.davem@davemloft.net>
References: <1280778294-2993-1-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cyril@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43510
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751189Ab0HCFJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 01:09:26 -0400
In-Reply-To: <1280778294-2993-1-git-send-email-cyril@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyril Chemparathy <cyril@ti.com>
Date: Mon,  2 Aug 2010 15:44:52 -0400

>   phy/marvell: add 88e1121 interface mode support

Applied.

>   phy/marvell: add 88ec048 support

You have to update marvel_id_tbl otherwise you break PHY
module autoloading.

Please fix this and resubmit this second patch.

Thanks.

