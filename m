From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] tg3: Add 1000T & 1000X flowctl adv helpers
Date: Thu, 20 Dec 2007 20:08:09 -0800 (PST)
Message-ID: <20071220.200809.169897554.davem@davemloft.net>
References: <1198191596.0@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57775
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753895AbXLUEIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:08:09 -0500
In-Reply-To: <1198191596.0@teletran1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 20 Dec 2007 14:59:56 -0800

> This patch adds two functions designed to convert abstract TX & RX
> flow control parameters to 1000-BaseT and 1000-BaseX autonegotiation
> advertisements.  Code that uses standard definitions which statically
> advertises TX & RX flow control has been replaced with code that
> configures the advertisements based on administrator dictated
> preferences.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

APplied.
