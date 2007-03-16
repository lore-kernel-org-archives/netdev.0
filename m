From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_mem initialization
Date: Thu, 15 Mar 2007 23:27:48 -0700 (PDT)
Message-ID: <20070315.232748.63125851.davem@davemloft.net>
References: <45F86842.8040305@psc.edu>
	<20070315.025839.104050310.davem@davemloft.net>
	<45F992E1.1060604@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41004
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752468AbXCPG1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 02:27:49 -0400
In-Reply-To: <45F992E1.1060604@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Thu, 15 Mar 2007 14:39:29 -0400

> The way it's coded is somewhat opaque since it has to be done with 
> 32-bit integer arithmetic.  These plots might help make the motivation 
> behind the code a little clearer.

Thanks John.

I was going to write a little test program to spit out
the values for a given range of memory sizes but your
graphs are much better :-)
