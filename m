From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] cxgb3: add memory barriers
Date: Wed, 03 Feb 2010 18:37:21 -0800 (PST)
Message-ID: <20100203.183721.78995928.davem@davemloft.net>
References: <20100201202929.23037.68116.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com, wenxiong@us.ibm.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36329
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750979Ab0BDChH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 21:37:07 -0500
In-Reply-To: <20100201202929.23037.68116.stgit@speedy5.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Mon, 01 Feb 2010 12:29:29 -0800

> From: Divy Le Ray <divy@chelsio.com>
> 
> Add memory barriers to fix crashes observed on newest PowerPC platforms.
> The HW and driver state of the receive rings were getting out of sync.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied, thanks.
