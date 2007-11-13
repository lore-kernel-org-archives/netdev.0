From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] remove references to net-modules.txt
Date: Mon, 12 Nov 2007 21:04:13 -0800 (PST)
Message-ID: <20071112.210413.17069543.davem@davemloft.net>
References: <20071109060141.GM26163@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48944
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750765AbXKMFEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:04:13 -0500
In-Reply-To: <20071109060141.GM26163@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Fri, 9 Nov 2007 07:01:41 +0100

> When I removed net-modules.txt because it only contained ancient 
> information I missed that many Kconfig entries pointed to this ancient 
> information.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied, thanks Adrian.
