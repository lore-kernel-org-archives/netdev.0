From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/usbnet: avoid recursive locking in usbnet_stop()
Date: Mon, 05 Mar 2012 16:40:25 -0500 (EST)
Message-ID: <20120305.164025.367232232901005595.davem@davemloft.net>
References: <20120220160148.GA7910@linutronix.de>
	<201202201721.38136.oliver@neukum.org>
	<20120305212500.GA8132@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: bigeasy@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876Ab2CEVle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 16:41:34 -0500
In-Reply-To: <20120305212500.GA8132@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Mon, 5 Mar 2012 22:25:00 +0100

> Is it okay for the patch to be merged?

Just simply make a fresh submission of it.
