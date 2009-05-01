From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] switch sgiseeq to netdev_ops
Date: Fri, 01 May 2009 15:30:33 -0700 (PDT)
Message-ID: <20090501.153033.144826920.davem@davemloft.net>
References: <20090501105932.7EC47C3C8B@solo.franken.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tsbogend@alpha.franken.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41914
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755444AbZEAWaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 18:30:39 -0400
In-Reply-To: <20090501105932.7EC47C3C8B@solo.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Date: Fri,  1 May 2009 12:59:32 +0200 (CEST)

> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>

This patch does not apply to net-next-2.6

That's because the driver is already converted in that tree.
