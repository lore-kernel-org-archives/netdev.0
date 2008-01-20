From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 9778] New: unregister_netdevice: waiting for
 [device] to become free
Date: Sun, 20 Jan 2008 02:30:27 -0800 (PST)
Message-ID: <20080120.023027.85710827.davem@davemloft.net>
References: <bug-9778-10286@http.bugzilla.kernel.org/>
	<20080119165802.2846a28e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, bugme-daemon@bugzilla.kernel.org,
	nigel@suspend2.net, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53915
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752029AbYATKaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 05:30:23 -0500
In-Reply-To: <20080119165802.2846a28e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Sat, 19 Jan 2008 16:58:02 -0800

> ouch.

Yep, several people are hitting this it seems.

If Pavel doesn't provide a fix or direction soon I'll just revert.
