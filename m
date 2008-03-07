From: David Miller <davem@davemloft.net>
Subject: Re: [BUILD_FAILURE] linux-next: Tree for March 6 build failure
Date: Fri, 07 Mar 2008 11:12:33 -0800 (PST)
Message-ID: <20080307.111233.14345956.davem@davemloft.net>
References: <47CFF332.4040807@linux.vnet.ibm.com>
	<20080306.111239.85901884.davem@davemloft.net>
	<47D0F269.8080900@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	apw@shadowen.org
To: kamalesh@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55361
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757288AbYCGTMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 14:12:33 -0500
In-Reply-To: <47D0F269.8080900@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Date: Fri, 07 Mar 2008 13:14:41 +0530

> Please find the .config attached and let me know if any other
> information is needed.

While waiting for your .config I reverted the change which
caused the build failure.
