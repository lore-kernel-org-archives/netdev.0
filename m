From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc9420: add ethtool register dump support
Date: Mon, 15 Dec 2008 01:00:10 -0800 (PST)
Message-ID: <20081215.010010.129872431.davem@davemloft.net>
References: <1229072252-7188-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vlad.lyalikov@smsc.com,
	ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34719
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752125AbYLOJAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 04:00:09 -0500
In-Reply-To: <1229072252-7188-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Fri, 12 Dec 2008 08:57:32 +0000

> This patch adds support for SMSC's LAN9420 PCI ethernet controller
> to ethtool's dump registers (-d) command.
> 
> This patch is for use with an accompanying ethtool patch, which decodes
> the register dump.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied, thanks Steve.
