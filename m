From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 7/11][IPV6] Make the ipv6/sysctl_net_ipv6.c
 compilation cleaner
Date: Wed, 05 Dec 2007 01:43:36 -0800 (PST)
Message-ID: <20071205.014336.156776097.davem@davemloft.net>
References: <4755256F.9000505@openvz.org>
	<475527CB.9000003@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38343
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751878AbXLEJnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:43:37 -0500
In-Reply-To: <475527CB.9000003@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 04 Dec 2007 13:11:23 +0300

> Since this file is entirely enclosed with the 
> #ifdef CONFIG_SYSCTL/#endif pair, it's OK to move this
> CONFIG_ into a Makefile.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
