From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: [BUILD_FAILURE] linux-next: Tree for March 6 build failure
Date: Thu, 06 Mar 2008 19:05:46 +0530
Message-ID: <47CFF332.4040807@linux.vnet.ibm.com>
References: <20080306162606.970aefe1.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP03.au.ibm.com ([202.81.18.172]:50227 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbYCFNfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 08:35:53 -0500
In-Reply-To: <20080306162606.970aefe1.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel build fails with error

net/built-in.o(.toc1+0x2060): undefined reference to `udplite_statistics'
net/built-in.o(.toc1+0x2100): undefined reference to `udplite_statistics'
make: *** [.tmp_vmlinux1] Error 1

-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
