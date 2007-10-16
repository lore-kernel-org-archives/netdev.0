From: David Miller <davem@davemloft.net>
Subject: Re: new NAPI interface broken
Date: Tue, 16 Oct 2007 00:44:10 -0700 (PDT)
Message-ID: <20071016.004410.85411180.davem@davemloft.net>
References: <200709071137.02801.ossthema@de.ibm.com>
	<20070912.055004.88490155.davem@davemloft.net>
	<1192519787.7205.3.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ossthema@de.ibm.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, themann@de.ibm.com, raisch@de.ibm.com
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51662
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760970AbXJPHoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 03:44:06 -0400
In-Reply-To: <1192519787.7205.3.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 16 Oct 2007 17:29:47 +1000

> Do you have any pointer to how that is done on x86 or sparc64 ?

Sparc64 does it statically in the kernel.

For x86, see http://irqbalance.org/
