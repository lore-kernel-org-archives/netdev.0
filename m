From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.18.1 hangs after resuming from apm suspend
Date: Mon, 23 Oct 2006 16:49:49 +0200
Message-ID: <200610231649.50077.rjw@sisk.pl>
References: <1381032543@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:60860 "EHLO ogre.sisk.pl")
	by vger.kernel.org with ESMTP id S964892AbWJWOuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2006 10:50:16 -0400
To: Christian stahl <stahl23@web.de>
In-Reply-To: <1381032543@web.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, 23 October 2006 09:47, Christian stahl wrote:
> After upgrading from 2.6.16.20 to 2.6.18.1 my Siemens Scenic
> Mobile 750AGP Notebook hangs after resuming from suspend.
> 
> However resuming from suspend works properly if:
> 
> - the prism 2.5 WLAN card is removed before suspending
> - the prism 2.5 WLAN is removed after resuming

This probably is a regression in the prism driver.

Well, it looks like you need to file a bug report at bugzilla.kernel.org.

Greetings,
Rafael


-- 
You never change things by fighting the existing reality.
		R. Buckminster Fuller
