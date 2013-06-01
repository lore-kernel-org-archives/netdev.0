From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: Implement initiate FW dump feature
 for Lancer
Date: Fri, 31 May 2013 17:27:26 -0700 (PDT)
Message-ID: <20130531.172726.1883166902346954147.davem@davemloft.net>
References: <ea8e2d9b-86e7-4ce3-a7a8-a576c73582ce@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kalesh.purayil@emulex.com
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43310 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755009Ab3FAA11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 20:27:27 -0400
In-Reply-To: <ea8e2d9b-86e7-4ce3-a7a8-a576c73582ce@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Thu, 30 May 2013 18:22:23 +0530

> Added code to initiate FW dump via ethtool. Driver checks if the previous dump
> has been cleared before initiating the dump. It doesn't initiate the dump
> if it is not cleared.
> 
> Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Applied.
