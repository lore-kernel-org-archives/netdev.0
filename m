From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 0/2] amd-xgbe: AMD XGBE driver fixes 2014-10-22
Date: Wed, 22 Oct 2014 17:51:01 -0400 (EDT)
Message-ID: <20141022.175101.764882957256655558.davem@davemloft.net>
References: <20141022162605.31495.98889.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932942AbaJVVvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 17:51:03 -0400
In-Reply-To: <20141022162605.31495.98889.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Wed, 22 Oct 2014 11:26:05 -0500

> The following series of patches includes fixes to the driver.
> 
> - Properly handle feature changes via ethtool by using correctly sized
>   variables
> - Perform proper napi packet counting and budget checking
> 
> This patch series is based on net.

Series applied, thanks Tom.
