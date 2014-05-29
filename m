From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] mdio: Parse DT nodes for auto-probed PHYs
Date: Thu, 29 May 2014 15:24:23 -0700 (PDT)
Message-ID: <20140529.152423.362592343606287617.davem@davemloft.net>
References: <1400916867-24573-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, mugunthanvnm@ti.com,
	ujhelyi.m@gmail.com
To: zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbaE2WY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 18:24:26 -0400
In-Reply-To: <1400916867-24573-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <zonque@gmail.com>
Date: Sat, 24 May 2014 09:34:24 +0200

> Here's v2.
> 
> v1 -> v2:
> 	* Switch to of_property_read_u32() in patch #1
> 	* Check for mdio->dev_of_node in patch #2
> 	* Added Florian's Reviewed-by: tags

Series applied to net-next, thank you.
