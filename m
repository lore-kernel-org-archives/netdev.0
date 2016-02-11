From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] virtio_net: better ethtool setting
 validation
Date: Thu, 11 Feb 2016 11:56:14 -0500 (EST)
Message-ID: <20160211.115614.1923342260282122052.davem@davemloft.net>
References: <1454878344-21730-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54633 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbcBKQ4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 11:56:18 -0500
In-Reply-To: <1454878344-21730-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Sun,  7 Feb 2016 21:52:22 +0100

> This small set is a follow-up for the recent patches that added ethtool
> get/set settings. Patch 1 changes the speed validation routine to check
> if the speed is between 0 and INT_MAX (or SPEED_UNKNOWN) and patch 2 adds
> port validation to virtio_net and better validation comment.
> 
> This set is on top of Michael's patch which explains that speeds from 0
> to INT_MAX are valid:
> http://patchwork.ozlabs.org/patch/578911/

Series applied, thanks.
