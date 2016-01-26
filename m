From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/2][pull request] Intel Wired LAN Driver Updates
 2016-01-25
Date: Mon, 25 Jan 2016 22:51:59 -0800 (PST)
Message-ID: <20160125.225159.1722142349535363848.davem@davemloft.net>
References: <1453766332-43274-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55471 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797AbcAZGwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 01:52:01 -0500
In-Reply-To: <1453766332-43274-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 25 Jan 2016 15:58:50 -0800

> This series contains updates to i40e only and so I won't continue receiving
> patches to fix the same issue (again).
> 
> Arnd fixes the driver from causing the compiler whining about uninitialized
> variables, so initialize those variables.
> 
> Eric fixes the build errors/warnings which were introduced by Anjali
> when she added geneve support to i40e.

Pulled, thanks Jeff.
