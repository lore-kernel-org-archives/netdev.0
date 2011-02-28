From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Mon, 28 Feb 2011 10:49:36 -0800 (PST)
Message-ID: <20110228.104936.193700342.davem@davemloft.net>
References: <20110228070732.GA2793@psychotron.redhat.com>
	<20110227.233013.226766890.davem@davemloft.net>
	<20110228092222.GA2831@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35017
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753793Ab1B1StA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 13:49:00 -0500
In-Reply-To: <20110228092222.GA2831@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Mon, 28 Feb 2011 10:22:24 +0100

> Applied incorrectly. net/core/dev.c part is missing

Fixed, sorry.
