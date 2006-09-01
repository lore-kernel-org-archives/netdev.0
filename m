From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/7] bonding: Miscellaneous small fixes
Date: Fri, 01 Sep 2006 18:31:06 -0400
Message-ID: <44F8B4AA.2080007@pobox.com>
References: <200609012207.k81M7qZt005145@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50340 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751129AbWIAWbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 18:31:14 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200609012207.k81M7qZt005145@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	Patch 1: Add 10 Gig support
> 	Patch 2: Convert delay value from s16 to int
> 	Patch 3: Format fix in seq_printf call
> 	Patch 4: Remove unneeded NULL test
> 	Patch 5: Handle large hard_header_len
> 	Patch 6: Add priv_flag to avoid event mishandling
> 	Patch 7: Don't release slaves when master is admin down

Will queue these up for 2.6.19.

	Jeff




-- 
VGER BF report: U 0.499948
