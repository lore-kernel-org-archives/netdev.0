From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: Convert to new vlan model.
Date: Mon, 27 Jun 2011 20:57:05 -0700 (PDT)
Message-ID: <20110627.205705.1246073299852202069.davem@davemloft.net>
References: <1308870279-30773-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sbhatewara@vmware.com,
	pv-drivers@vmware.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54383 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756506Ab1F1D5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 23:57:08 -0400
In-Reply-To: <1308870279-30773-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Thu, 23 Jun 2011 16:04:39 -0700

> This converts the vmxnet3 driver to use the new vlan model.  In doing so
> it fixes missing tags in tcpdump and failure to do checksum offload when
> tx vlan offload is disabled.
> 
> CC: Shreyas Bhatewara <sbhatewara@vmware.com>
> CC: VMware PV-Drivers <pv-drivers@vmware.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied, thanks.
