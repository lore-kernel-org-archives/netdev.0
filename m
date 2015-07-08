From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_core: Add extra check for total vfs
 for SRIOV
Date: Wed, 08 Jul 2015 15:20:06 -0700 (PDT)
Message-ID: <20150708.152006.2183671569620167581.davem@davemloft.net>
References: <1436192419-25303-1-git-send-email-clsoto@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, jackm@mellanox.com
To: clsoto@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbbGHWUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 18:20:07 -0400
In-Reply-To: <1436192419-25303-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: clsoto@linux.vnet.ibm.com
Date: Mon,  6 Jul 2015 09:20:19 -0500

> From: Carol Soto <clsoto@linux.vnet.ibm.com>
> 
> Add extra check for total vfs for SRIOV to check if that value is 
> bigger than total vfs in pci SRIOV capabalities. Fix a check and 
> print of the number of maximum vfs that hw can handle. Fix a check 
> and print of the number of maximum vfs per port that driver can handle. 
> 
> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>

Applied, thanks.
