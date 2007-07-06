From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/core/netevent.c should #include
 <net/netevent.h>
Date: Thu, 05 Jul 2007 17:07:13 -0700 (PDT)
Message-ID: <20070705.170713.32063175.davem@davemloft.net>
References: <20070705232217.GS3492@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@opengridcomputing.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35736
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750880AbXGFAGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 20:06:53 -0400
In-Reply-To: <20070705232217.GS3492@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 6 Jul 2007 01:22:17 +0200

> Every file should include the headers containing the prototypes for
> its global functions.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
