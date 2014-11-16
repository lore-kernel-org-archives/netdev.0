From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] device: Add dev_<level>_once variants
Date: Sun, 16 Nov 2014 15:49:23 -0500 (EST)
Message-ID: <20141116.154923.1364136096942964102.davem@davemloft.net>
References: <1416031715-32498-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<5467C3BA.6090003@gmail.com>
	<1416091109.5912.32.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, jeffrey.t.kirsher@intel.com,
	shannon.nelson@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38388 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbaKPUt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 15:49:26 -0500
In-Reply-To: <1416091109.5912.32.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sat, 15 Nov 2014 14:38:29 -0800

> Add the equivalents to pr_<level>_once.
> 
> Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Joe Perches <joe@perches.com>

This probably should go via the device layer core, thanks thus Greg KH.
