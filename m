From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] iucv: fix memory leak in cpu hotplug error path.
Date: Tue, 15 Jul 2008 02:10:04 -0700 (PDT)
Message-ID: <20080715.021004.33973618.davem@davemloft.net>
References: <20080715081025.GB22068@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ubraun@linux.vnet.ibm.com, linux390@de.ibm.com,
	linux-s390@vger.kernel.org
To: akinobu.mita@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58531
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753853AbYGOJKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 05:10:05 -0400
In-Reply-To: <20080715081025.GB22068@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Tue, 15 Jul 2008 17:10:25 +0900

> Fix memory leak in error path in CPU_UP_PREPARE notifier.
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>

Applied, thank you.
