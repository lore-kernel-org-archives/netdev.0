From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] be2net: remove superfluous externs
Date: Sat, 29 May 2010 00:20:15 -0700 (PDT)
Message-ID: <20100529.002015.173876275.davem@davemloft.net>
References: <20100526144739.GM22515@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathyap@serverengines.com, subbus@serverengines.com,
	sarveshwarb@serverengines.com, ajitk@serverengines.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38371
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753696Ab0E2HUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 May 2010 03:20:05 -0400
In-Reply-To: <20100526144739.GM22515@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 26 May 2010 16:47:39 +0200

> This fixes some sparse warnings:
> drivers/net/benet/be_cmds.c:1503:12: warning: function
> 	'be_cmd_enable_magic_wol' with external linkage has definition
> drivers/net/benet/be_cmds.c:1668:12: warning: function
> 	'be_cmd_get_seeprom_data' with external linkage has definition
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
