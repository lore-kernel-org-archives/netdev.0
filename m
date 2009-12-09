From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Fix Yukon-2 Optima TCP offload setup
Date: Tue, 08 Dec 2009 20:16:29 -0800 (PST)
Message-ID: <20091208.201629.04776668.davem@davemloft.net>
References: <1259853122-21134-1-git-send-email-tiwai@suse.de>
	<1259853122-21134-2-git-send-email-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tiwai@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55855
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756549AbZLIEQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:16:22 -0500
In-Reply-To: <1259853122-21134-2-git-send-email-tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Takashi Iwai <tiwai@suse.de>
Date: Thu,  3 Dec 2009 16:12:01 +0100

> Fix the TCP offload setup for Yukon-2 Optima.
> It requires SKY2_HW_NE_LE flag unlike Ultra 2.
> 
> Signed-off-by: Takashi Iwai <tiwai@suse.de>

Stephen, you said last week you were going to stick this card type
into one of your systems and give these patches a test.

How's that coming along?

These two patches are just rotting at the bottom of patchwork.
