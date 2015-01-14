From: David Miller <davem@davemloft.net>
Subject: Re: [net] i40e: adds FCoE configure option
Date: Wed, 14 Jan 2015 16:49:05 -0500 (EST)
Message-ID: <20150114.164905.380452395727324454.davem@davemloft.net>
References: <1421241247-22594-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vasu.dev@intel.com, netdev@vger.kernel.org, nhorman@redhat.com,
	sassmann@redhat.com, jogreene@redhat.com, stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754612AbbANVtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 16:49:07 -0500
In-Reply-To: <1421241247-22594-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 14 Jan 2015 05:14:07 -0800

> From: Vasu Dev <vasu.dev@intel.com>
> 
> Adds FCoE config option I40E_FCOE, so that FCoE can be enabled
> as needed but otherwise have it disabled by default.
> 
> This also eliminate multiple FCoE config checks, instead now just
> one config check for CONFIG_I40E_FCOE.
> 
> The I40E FCoE was added with 3.17 kernel and therefore this patch
> shall be applied to stable 3.17 kernel also.
> 
> CC: <stable@vger.kernel.org>
> Signed-off-by: Vasu Dev <vasu.dev@intel.com>
> Tested-by: Jim Young <jamesx.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
