From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v8] Add support of Cavium Liquidio ethernet
 adapters
Date: Wed, 10 Jun 2015 22:45:40 -0700 (PDT)
Message-ID: <20150610.224540.1200146585784467644.davem@davemloft.net>
References: <20150427.132242.1898729531212160949.davem@davemloft.net>
	<1433898923-7350-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	Robert.Richter@caviumnetworks.com,
	Aleksey.Makarov@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58170 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbbFKFpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 01:45:44 -0400
In-Reply-To: <1433898923-7350-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Tue, 9 Jun 2015 18:15:23 -0700

> Following patch V8 adds support for Cavium Liquidio pci express
> based 10Gig ethernet adapters.
> 1) Consolidated all debug macros to either call dev_* or
>    netdev_* macros directly, feedback from previous patch.
> 2) Changed soft commands to avoid crash when running
>    in interrupt context.
> 3) Fixed link status not reflecting correct status when NetworkManager
>    is running. Added MODULE_FIRMWARE declarations.

Applied, thank you.
