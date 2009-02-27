From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: bluetooth-next-2.6 2009-02-27
Date: Thu, 26 Feb 2009 22:51:29 -0800 (PST)
Message-ID: <20090226.225129.93967402.davem@davemloft.net>
References: <1235712929.27004.38.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34946
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752543AbZB0Gvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 01:51:45 -0500
In-Reply-To: <1235712929.27004.38.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Fri, 27 Feb 2009 06:35:29 +0100

> these are the Bluetooth patches for the 2.6.30 kernel release. All of
> them have been in bluetooth-testing.git for a while. We tested them
> heavily at the last UnPlugFest and also against the qualification test
> system.
> 
> The majority of these patches improve the Simple Pairing support and
> ensures that we have the best interoperability while enforcing the best
> possible security protection.
> 
> The problems with SCO/eSCO establishment should now all be fixed. Some
> Bluetooth chips are just too stupid to do the right thing.
> 
> The Android guys found a few race conditions with the L2CAP connection
> setup and they should also be fixed now.
> 
> The Bluetooth USB driver now submits its bulk URBs together with the
> interrupt URBs. This is a stupid requirement, but some Bluetooth chips
> didn't like the missing bulk URBs at all.
 ...
>     git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-next-2.6.git master

Pulled, thanks a lot Marcel.
