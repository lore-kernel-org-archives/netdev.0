From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix race when opening a proc file while a network
 namespace is exiting.
Date: Thu, 13 Sep 2007 00:19:55 -0700 (PDT)
Message-ID: <20070913.001955.85390949.davem@davemloft.net>
References: <m14phzam2l.fsf@ebiederm.dsl.xmission.com>
	<20070912224653.GK9830@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:43401
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751677AbXIMHUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 03:20:07 -0400
In-Reply-To: <20070912224653.GK9830@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Wed, 12 Sep 2007 15:46:53 -0700

> Looks much better!
> 
> Acked-by: Paul E. McKenney <paulmck@us.ibm.com>

Applied, thanks everyone.
