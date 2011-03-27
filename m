From: David Miller <davem@davemloft.net>
Subject: Re: disabling ipv6 (when ipv6 module is already loaded or built in)
Date: Sun, 27 Mar 2011 14:24:36 -0700 (PDT)
Message-ID: <20110327.142436.226789238.davem@davemloft.net>
References: <201103252353.06297.a.miskiewicz@gmail.com>
	<20110325.155657.193733904.davem@davemloft.net>
	<201103272319.16022.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: a.miskiewicz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57555
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750960Ab1C0VZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 17:25:14 -0400
In-Reply-To: <201103272319.16022.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Date: Sun, 27 Mar 2011 23:19:15 +0200

> Hm, maybe then it could be done in a way where ipv6 is initially built in but 
> disabled and could be permanently enabled via sysfs/proc/something based on a 
> userspace (or user/admin) decision runtime? That would be analogous to 
> "modprobe ipv6" in kernel with modular ipv6.

Sorry, no.

We believe the current facilities handle all reasonable uses of the
feature.
