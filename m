From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] tg3: tg3.h cleanups
Date: Sun, 21 Dec 2008 20:22:45 -0800 (PST)
Message-ID: <20081221.202245.18142923.davem@davemloft.net>
References: <1229717361.5505@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41171
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752922AbYLVEWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 23:22:43 -0500
In-Reply-To: <1229717361.5505@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 18 Dec 2008 16:55:29 -0800

> This patch cleans up the tg3 header file by removing the preprocessor
> definitions for standard PCI configuration space registers.  The driver
> should be using the standard definitions when needed.  The patch
> continues by removing redundant PHY related definitions and reorganizes
> some of the remaining entries.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
