From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] enic: Add adaptive coalescing
 interrupt support
Date: Wed, 21 May 2014 17:05:01 -0400 (EDT)
Message-ID: <20140521.170501.1363589551886040862.davem@davemloft.net>
References: <1400535762-13318-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benve@cisco.com, neepatel@cisco.com,
	ssujith@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56027 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837AbaEUVFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 17:05:04 -0400
In-Reply-To: <1400535762-13318-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Tue, 20 May 2014 03:12:42 +0530

> This series add support for adaptive coalescing interrupt and updates 
> enic Maintainers.
> 
> v1->v2:
> 	* Add commit log
> 	* do vnic_intr_coalescing_timer_set only while enabling intr
> 	* use ktime_get instead of hrtimer
> 	* make enic_set_rx_coal_setting return type void
> 	* change func name enic_apply_int_moderation to enic_calc_int_moderation

Series applied, thank you.
