From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] tg3: Allow 5761 WOL and LED fixes to 5761S too
Date: Tue, 21 Apr 2009 01:42:14 -0700 (PDT)
Message-ID: <20090421.014214.219170674.davem@davemloft.net>
References: <1240247958.7021@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, benli@broadcom.com,
	andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54733
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751932AbZDUImW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 04:42:22 -0400
In-Reply-To: <1240247958.7021@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 20 Apr 2009 09:58:01 -0700

> The 5761 WOL and LED fixes used the PCI device ID to as the activation
> key.  The 5761S requires the same process.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
