From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] be2net: Clear any capability flags that driver
 is not interested in.
Date: Thu, 15 Aug 2013 01:22:31 -0700 (PDT)
Message-ID: <20130815.012231.2044765464344269286.davem@davemloft.net>
References: <07165eb6-9b8f-45b4-bec6-bb53f0e1aa52@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwar.bandi@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170Ab3HOIWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 04:22:32 -0400
In-Reply-To: <07165eb6-9b8f-45b4-bec6-bb53f0e1aa52@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <sarveshwar.bandi@emulex.com>
Date: Wed, 14 Aug 2013 13:21:47 +0530

> From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
> 
> It is possible for some versions of firmware to advertise capabilities that driver
> is not ready to handle. This may lead to controller stall. Since the driver is
> interested only in subset of flags, clearing the rest.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Applied, thanks.
