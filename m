From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
 (v3)
Date: Tue, 05 Jan 2010 13:45:37 -0800 (PST)
Message-ID: <20100105.134537.244111255.davem@davemloft.net>
References: <4B4357A9.5010507@gmail.com>
	<20100105.124040.192660261.davem@davemloft.net>
	<20100105213856.GB24245@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48925
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753780Ab0AEVpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 16:45:32 -0500
In-Reply-To: <20100105213856.GB24245@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 5 Jan 2010 16:38:56 -0500

> I think thats what I've done in my third version of the patch here.
> By raising the copybreak value, and setting an initial allocation
> size of 16k, we:

Right, I'll take an even closer look at your patch later this
afternoon, thanks Neil.
