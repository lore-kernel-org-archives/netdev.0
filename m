From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/11][CORE] Remove unneeded ifdefs from
 sysctl_net_core.c
Date: Wed, 05 Dec 2007 01:36:33 -0800 (PST)
Message-ID: <20071205.013633.100450557.davem@davemloft.net>
References: <4755256F.9000505@openvz.org>
	<475525DA.3050002@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39659
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751522AbXLEJge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:36:34 -0500
In-Reply-To: <475525DA.3050002@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 04 Dec 2007 13:03:06 +0300

> This file is already compiled out when the SYSCTL=n, so
> these ifdefs, that enclose the whole file, can be removed.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
