From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 8/9] Resending NetXen 1G/10G NIC driver patch
Date: Fri, 26 May 2006 09:08:42 -0700
Message-ID: <20060526090842.6572a3da@localhost.localdomain>
References: <Pine.LNX.4.33.0605250356420.5844-100000@unmsrvr>
	<20060525100339.40b19371@dxpl.pdx.osdl.net>
	<1148653616.3453.115.camel@arya.linsyssoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	UNM Project Staff <unmproj@linsyssoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:5539 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750968AbWEZQIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 12:08:50 -0400
To: pradeep@linsyssoft.com
In-Reply-To: <1148653616.3453.115.camel@arya.linsyssoft.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You might also want to add support for setting
	dev->perm_addr 
and using ethtool_op_get_perm_addr() in ethtool_ops
