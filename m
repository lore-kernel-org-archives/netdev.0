From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix incorrect usage of strncat in bdx_get_drvinfo();
 drivers/net/tehuti.c
Date: Tue, 13 Nov 2007 03:17:29 -0800 (PST)
Message-ID: <20071113.031729.155210307.davem@davemloft.net>
References: <472F807B.3050901@tiscali.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: 12o3l@tiscali.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49064
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751527AbXKMLRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 06:17:30 -0500
In-Reply-To: <472F807B.3050901@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roel Kluin <12o3l@tiscali.nl>
Date: Mon, 05 Nov 2007 21:43:39 +0100

> Fix incorrect length for strncat by replacing it with strlcat
> 
> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>

Applied, thanks.
