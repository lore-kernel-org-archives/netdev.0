From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3]S2io: Fix IOMMU overflow checking.
Date: Fri, 11 Jul 2008 01:14:17 -0400
Message-ID: <4876EC29.80607@garzik.org>
References: <Pine.GSO.4.10.10807092346390.5252-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46478 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911AbYGKFOV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 01:14:21 -0400
In-Reply-To: <Pine.GSO.4.10.10807092346390.5252-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> - Fix IOMMU overflow checking. As reported by Andi Kleen <ak@linux.intel.com> 
> removed check for zero dma address.
> 
> Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

applied 1-3


