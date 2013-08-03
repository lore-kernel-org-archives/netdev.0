From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/8] qlcnic: Bug fixes
Date: Sat, 03 Aug 2013 12:03:17 -0700 (PDT)
Message-ID: <20130803.120317.2224762299381503635.davem@davemloft.net>
References: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52381 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782Ab3HCTDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 15:03:18 -0400
In-Reply-To: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Fri, 2 Aug 2013 23:15:53 -0400

> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> This patch series contains the following bug fixes :
> 
> * Fix programming of MAC address filter.
> * Fix MAC address learning of ingress packets.
> * Free memory in error path.
> * Remove adapter series name from warning messages.
> * Fix external loopback diagnostic test.
> * Fix improper link speed display.
> * Fix flash update failure due to improper error handling of
>   read register API.
> 
> Please apply this series to net.

Series applied, thanks.
