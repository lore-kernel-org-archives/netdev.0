From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 3/9] iPhase: 64bit cleanup
Date: Fri, 10 Nov 2006 01:35:14 +0000
Message-ID: <1163122514.7900.3.camel@localhost.localdomain>
References: <200611090351.kA93p4ho003684@shell0.pdx.osdl.net>
	 <20061109.161230.71161297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, alan@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:38073 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1424326AbWKJBbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 20:31:10 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061109.161230.71161297.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Iau, 2006-11-09 am 16:12 -0800, ysgrifennodd David Miller:
> Really, this driver has a ton of unresolved portability problems.

Agreed - but at least its now 64bit clean. No objection to leaving it !
64BIT at all even with the patch merged.

