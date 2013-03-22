From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add support for handling queueing in hardware
Date: Fri, 22 Mar 2013 10:33:02 -0400 (EDT)
Message-ID: <20130322.103302.1277256650283142022.davem@davemloft.net>
References: <E1UJ1fR-0004hs-4l@swissweb.swissdisk.com>
	<20130322.101139.1942128058226201237.davem@davemloft.net>
	<A5ACC15C-361D-48E6-BFFF-9AA3966C2A68@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ben.c@servergy.com
To: afleming@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <A5ACC15C-361D-48E6-BFFF-9AA3966C2A68@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fleming Andy-AFLEMING <afleming@freescale.com>
Date: Fri, 22 Mar 2013 14:31:50 +0000

> It would appear one of our customers is attempting to upstream our
> code for us. We are aware that this current solution is unacceptable
> (which is why we have not submitted it), and we are currently trying
> to develop a less hacky solution that integrates with qdisc.

Ben, can can you coordinate with people instead of doing crap like
this?
