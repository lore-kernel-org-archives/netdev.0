From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] i40e: Fix for stats init function call in Rx setup
Date: Mon, 09 Feb 2015 18:45:21 -0800 (PST)
Message-ID: <20150209.184521.1007587457049096797.davem@davemloft.net>
References: <1423532551-13843-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: carolyn.wyborny@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbbBJCpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 21:45:25 -0500
In-Reply-To: <1423532551-13843-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon,  9 Feb 2015 17:42:31 -0800

> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> This patch fixes indentation issue and error found in argument
> reported by static analysis.  Without this patch, sparse and other
> static analysis errors will be found.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Reported-by: Julia Lawall <julia.lawall@lip6.fr>
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
