From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dcb : Fix incorrect documentation for struct
 dcb_app
Date: Tue, 23 Jun 2015 07:00:56 -0700 (PDT)
Message-ID: <20150623.070056.1653977816535810810.davem@davemloft.net>
References: <1435020275-2819-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	shanim@mellanox.com, ogerlitz@mellanox.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933434AbbFWNtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 09:49:07 -0400
In-Reply-To: <1435020275-2819-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Mon, 22 Jun 2015 17:44:35 -0700

> While IEEE and CEE use the same structure to store apps, the selector
> and priority fields for both are different. Only the priority field is
> explained, add documentation explaining how the selector field differs
> for both.
> 
> cgdcbxd code shows an example of how selector fields differ.
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

Applied.
