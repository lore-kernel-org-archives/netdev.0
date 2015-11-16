From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] be2net: remove unused local rsstable array
Date: Mon, 16 Nov 2015 14:46:27 -0500 (EST)
Message-ID: <20151116.144627.132708403660718020.davem@davemloft.net>
References: <1447411018-11745-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sriharsha.basavapatna@avagotech.com,
	sathya.perla@avagotech.com, ajit.khaparde@avagotech.com,
	padmanabh.ratnakar@avagotech.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40347 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbbKPTq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 14:46:29 -0500
In-Reply-To: <1447411018-11745-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Fri, 13 Nov 2015 11:36:57 +0100

> Remove rsstable array and its initialization from be_set_rss_hash_opts().
> The array became unused after "e255787 be2net: Support for configurable
> RSS hash key". The initial RSS table is now filled and stored for later
> usage during Rx queue creation.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied.
