From: David Miller <davem@davemloft.net>
Subject: Re: bnx2 dirver's firmware images
Date: Wed, 19 Sep 2007 09:38:32 -0700 (PDT)
Message-ID: <20070919.093832.88002774.davem@davemloft.net>
References: <20070918.112337.74737433.davem@davemloft.net>
	<1190145951.9540.230.camel@dell>
	<20070919163318.GG6618@stro.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: max@stro.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42925
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752240AbXISQis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 12:38:48 -0400
In-Reply-To: <20070919163318.GG6618@stro.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: maximilian attems <max@stro.at>
Date: Wed, 19 Sep 2007 18:33:18 +0200

> we have to strip the firmware for Debian for the upcoming Lenny release.

Why do you "have to"?  The vendor has given you explicit rights
to distribute it:

 * Firmware is:
 *	Derived from proprietary unpublished source code,
 *	Copyright (C) 2000-2003 Broadcom Corporation.
 *
 *	Permission is hereby granted for the distribution of this firmware
 *	data in hexadecimal or equivalent format, provided this copyright
 *	notice is accompanying it.

This whole firmware stripping thing in debian is beyond rediculious
and only serves to hurt users.
