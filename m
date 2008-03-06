From: David Miller <davem@davemloft.net>
Subject: Re: [BUILD_FAILURE] linux-next: Tree for March 6 build failure
Date: Thu, 06 Mar 2008 11:12:39 -0800 (PST)
Message-ID: <20080306.111239.85901884.davem@davemloft.net>
References: <20080306162606.970aefe1.sfr@canb.auug.org.au>
	<47CFF332.4040807@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	apw@shadowen.org
To: kamalesh@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37255
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761962AbYCFTMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 14:12:40 -0500
In-Reply-To: <47CFF332.4040807@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Date: Thu, 06 Mar 2008 19:05:46 +0530

> The kernel build fails with error
> 
> net/built-in.o(.toc1+0x2060): undefined reference to `udplite_statistics'
> net/built-in.o(.toc1+0x2100): undefined reference to `udplite_statistics'
> make: *** [.tmp_vmlinux1] Error 1

Please provide your .config so that others have a chance
to reproduce and fix this.

Thank you.
