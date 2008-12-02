From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] etherh: build fix for net-next
Date: Tue, 02 Dec 2008 14:52:42 -0800 (PST)
Message-ID: <20081202.145242.121211524.davem@davemloft.net>
References: <20081201153030.235a8c84@extreme>
	<4934B7B5.9010004@oracle.com>
	<20081202075850.036421a2@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, jgarzik@pobox.com, rmk@arm.linux.org.uk,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36961
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752626AbYLBWwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 17:52:42 -0500
In-Reply-To: <20081202075850.036421a2@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 2 Dec 2008 07:58:50 -0800

> Fix build of ARM etherh driver with new net_device_ops.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks for fixing this Stephen.
