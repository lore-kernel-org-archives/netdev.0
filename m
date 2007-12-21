From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/8] tg3: Replace some magic 5704S constants
Date: Thu, 20 Dec 2007 20:08:39 -0800 (PST)
Message-ID: <20071220.200839.136849205.davem@davemloft.net>
References: <1198191599.0@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57781
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754766AbXLUEIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:08:40 -0500
In-Reply-To: <1198191599.0@teletran1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 20 Dec 2007 14:59:59 -0800

> This patch replaces magic values with preprocessor definitions for
> the sg_dig_ctrl and sg_dig_status registers.  This is preparatory work
> for the next patch.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
