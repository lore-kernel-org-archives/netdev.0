From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] Fix tx flit calculation and wc stat
 configuration
Date: Wed, 09 Sep 2015 12:29:42 -0700 (PDT)
Message-ID: <20150909.122942.1418256564982647578.davem@davemloft.net>
References: <1441709740-7533-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34264 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbbIIT3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 15:29:43 -0400
In-Reply-To: <1441709740-7533-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue,  8 Sep 2015 16:25:38 +0530

> This patch series fixes the following:
> Patch 1/2 fixes tx flit calculation, which if wrong can lead to 
> stall, hang, data corrpution, write combining failure. Patch 2/2 fixes 
> PCI-E write combining stats configuration.
> 
> This patch series has been created against net tree and includes
> patches on cxgb4 driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.

Series applied, thanks.
