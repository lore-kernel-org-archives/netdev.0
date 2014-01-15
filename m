From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/6] Intel Wired LAN Driver Updates
Date: Tue, 14 Jan 2014 18:56:32 -0800 (PST)
Message-ID: <20140114.185632.1627132863040616582.davem@davemloft.net>
References: <1389689394-22369-1-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54645 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaAOC4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 21:56:33 -0500
In-Reply-To: <1389689394-22369-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Brown <aaron.f.brown@intel.com>
Date: Tue, 14 Jan 2014 00:49:48 -0800

> This series contains updates to i40e that are primarily minor fixes or 
> general cleanup.
> 
> Shannon fixes a bug where the VMDq queue is not associated with the
> right setup within the hardware.
> 
> Mitch provides a patch adjusting where the VF is reset and another
> one adding meaningful context to a message.
> 
> Jesse cleans up white space comments and parenthesis.  
> 
> Catherine bumps the version.

Series applied, thanks.
