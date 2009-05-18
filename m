From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] de600: convert PRINTK() to pr_debug()
Date: Sun, 17 May 2009 21:07:44 -0700 (PDT)
Message-ID: <20090517.210744.142686514.davem@davemloft.net>
References: <1242418962-1272-1-git-send-email-a.beregalov@gmail.com>
	<1242418962-1272-2-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45068
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751187AbZEREHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 00:07:46 -0400
In-Reply-To: <1242418962-1272-2-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Sat, 16 May 2009 00:22:39 +0400

> Also remove de600_debug as it is not needed.
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

Applied to net-next-2.6
