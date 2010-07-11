From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: Patch to determine if function is
 VF while running in guest OS.
Date: Sat, 10 Jul 2010 19:42:15 -0700 (PDT)
Message-ID: <20100710.194215.35032919.davem@davemloft.net>
References: <20100709114344.GA2392@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwarb@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39871
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753240Ab0GKCmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 22:42:00 -0400
In-Reply-To: <20100709114344.GA2392@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Date: Fri, 9 Jul 2010 17:13:55 +0530

> When driver is loaded in guest OS, the pci variables is_virtfn and is_physfn are
> both set to 0. This change uses registers in controller to determine the same.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>

Applied.
