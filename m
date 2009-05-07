From: David Miller <davem@davemloft.net>
Subject: Re: via velocity trivial patch
Date: Thu, 07 May 2009 15:02:13 -0700 (PDT)
Message-ID: <20090507.150213.192379856.davem@davemloft.net>
References: <49F1A05A.8070802@podgorny.cz>
	<4A01FBF6.1090001@podgorny.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: radek@podgorny.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53510
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754502AbZEGWCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 18:02:18 -0400
In-Reply-To: <4A01FBF6.1090001@podgorny.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Radek Podgorny <radek@podgorny.cz>
Date: Wed, 06 May 2009 23:07:02 +0200

> I've sent the following mail to Francois Romieu <romieu@fr.zoreil.com>
> but did not get any reply. So I'm sending directly here. It's a trivial
> patch for via-velocity driver.

"some garbage"...

Why would the interrupt status register give us all 1's
if it is properly initialized?  I should report a zero,
rather than "some garbage".

You also failed to provide a proper sign-off as described
in Documentation/SubmittingPatches
