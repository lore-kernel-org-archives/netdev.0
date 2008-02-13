From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3][NETLABLE]: Hide netlbl_unlabel_audit_addr6 under
 ifdef CONFIG_IPV6.
Date: Tue, 12 Feb 2008 22:38:14 -0800 (PST)
Message-ID: <20080212.223814.205889467.davem@davemloft.net>
References: <47AB3F20.2030809@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753404AbYBMGhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 01:37:43 -0500
In-Reply-To: <47AB3F20.2030809@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 07 Feb 2008 20:25:52 +0300

> This one is called from under this config only, so move
> it in the same place.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.

