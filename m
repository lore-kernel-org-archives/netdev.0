From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: Fix a UDP socket reference count bug in the
 pppol2tp driver
Date: Thu, 28 Jan 2010 06:07:17 -0800 (PST)
Message-ID: <20100128.060717.99647383.davem@davemloft.net>
References: <20100121161009.5223.34288.stgit@bert.katalix.com>
	<20100123.015511.83860202.davem@davemloft.net>
	<4B603C50.20406@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39350
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753420Ab0A1OHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 09:07:05 -0500
In-Reply-To: <4B603C50.20406@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Wed, 27 Jan 2010 13:14:56 +0000

> Does the above help?

Thanks for the detailed explanation, I'll take another look
at this.
