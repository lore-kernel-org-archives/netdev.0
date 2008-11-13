From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/5] bnx2: Set rx buffer water marks based on
 MTU.
Date: Wed, 12 Nov 2008 16:02:27 -0800 (PST)
Message-ID: <20081112.160227.231596086.davem@davemloft.net>
References: <1226531404-26118-1-git-send-email-mchan@broadcom.com>
	<1226531404-26118-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37842
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752920AbYKMAC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 19:02:27 -0500
In-Reply-To: <1226531404-26118-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 12 Nov 2008 15:10:02 -0800

> The default rx buffer water marks for XOFF/XON are for 1500 MTU.  At
> larger MTUs, these water marks need to be adjusted for effective
> flow control.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied.
