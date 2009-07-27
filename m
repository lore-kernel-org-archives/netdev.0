From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] imwc3200: move iwmc3200 SDIO ids to sdio_ids.h
Date: Sun, 26 Jul 2009 19:50:05 -0700 (PDT)
Message-ID: <20090726.195005.189598415.davem@davemloft.net>
References: <1248307616-30631-1-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: tomas.winkler@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56712
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755796AbZG0Ct6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 22:49:58 -0400
In-Reply-To: <1248307616-30631-1-git-send-email-tomas.winkler@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomas Winkler <tomas.winkler@intel.com>
Date: Thu, 23 Jul 2009 03:06:56 +0300

> 1. add intel's sdio vendor id to sdio_ids.h
> 2. move iwmc3200 sdio devices' ids to sdio_ids.h
> 
> Cc:inaky.perez-gonzalez@intel.com
> Cc:cindy.h.kao@intel.com
> Cc:yi.zhu@intel.com
> Cc:drzeus-list@drzeus.cx
> Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>

Applied to net-next-2.6
