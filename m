From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: Fix smatch warnings in be_main.c
Date: Tue, 23 Oct 2012 13:05:17 -0400 (EDT)
Message-ID: <20121023.130517.190568793040091162.davem@davemloft.net>
References: <60b05fee-7c4f-42f9-ae31-be214fe65d41@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vasundhara.volam@emulex.com,
	sathya.perla@emulex.com
To: padmanabh.ratnakar@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42155 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932821Ab2JWRFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:05:19 -0400
In-Reply-To: <60b05fee-7c4f-42f9-ae31-be214fe65d41@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Date: Tue, 23 Oct 2012 14:32:44 +0530

> FW flashing code, even though it works correctly, makes some hidden
> assumptions about buffer sizes. This is causing code analysers to
> report error. Cleanup FW flashing code to remove these hidden assumptions.
> 
> Reported-by: Yuanhan Liu <yuanhan.liu@intel.com>
> Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>

Applied.
