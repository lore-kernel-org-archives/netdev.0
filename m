From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] genetlink: remove ops_list from genetlink
 header.
Date: Mon, 05 Jun 2017 10:55:26 -0400 (EDT)
Message-ID: <20170605.105526.613614281136063379.davem@davemloft.net>
References: <1496578801-9270-1-git-send-email-rami.rosen@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes.berg@intel.com, netdev@vger.kernel.org
To: rami.rosen@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37686 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751112AbdFEOz2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 10:55:28 -0400
In-Reply-To: <1496578801-9270-1-git-send-email-rami.rosen@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <rami.rosen@intel.com>
Date: Sun,  4 Jun 2017 15:20:01 +0300

> commit d91824c08fbc ("genetlink: register family ops as array") removed the 
> ops_list member from both genl_family and genl_ops; while the 
> documentation of genl_family was updated accordingly by this patch, 
> ops_list remained in the documentation of the genl_ops object. 
> This patch fixes it by removing ops_list from genl_ops documentation. 
> 
> Signed-off-by: Rami Rosen <rami.rosen@intel.com>

Applied, thank you.
