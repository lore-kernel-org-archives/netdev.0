From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: Fallback to the older opcode if
 MCC_CREATE_EXT opcode is not supported on the card
Date: Tue, 31 May 2011 22:15:40 -0700 (PDT)
Message-ID: <20110531.221540.52563391.davem@davemloft.net>
References: <73fd9a8d-d3cb-4913-952c-d7b841d84f58@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501Ab1FAFPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 01:15:55 -0400
In-Reply-To: <73fd9a8d-d3cb-4913-952c-d7b841d84f58@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@Emulex.Com>
Date: Wed, 1 Jun 2011 16:03:22 +0530

> Instead of failing the init/probe code in the driver fallback to the older opcode to ensure
> the driver is loaded thereby enabling users to upgrade the f/w to whatever version is required.
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Applied.
