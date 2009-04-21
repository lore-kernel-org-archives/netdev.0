From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/8] tg3: Prevent send BD corruption
Date: Tue, 21 Apr 2009 01:42:04 -0700 (PDT)
Message-ID: <20090421.014204.141098433.davem@davemloft.net>
References: <1240247957.7018@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, benli@broadcom.com,
	andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54729
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752490AbZDUImM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 04:42:12 -0400
In-Reply-To: <1240247957.7018@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 20 Apr 2009 09:57:41 -0700

> On rare occasions, send BD corruptions can occur.  This patch
> fixes the problem by increasing the L1 entry threshold to 4
> milliseconds.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
