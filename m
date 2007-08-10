From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [PATCH] [NET] ethtool: Add LRO support
Date: Fri, 10 Aug 2007 09:47:13 +0200
Message-ID: <200708100947.13486.ossthema@de.ibm.com>
References: <20070809164117.9907.23351.stgit@localhost.localdomain> <20070809.150014.32064726.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, jeff@garzik.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:16373 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755478AbXHJIRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 04:17:43 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id l7A8Hg3u132384
	for <netdev@vger.kernel.org>; Fri, 10 Aug 2007 08:17:42 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l7A8Hg0F2125988
	for <netdev@vger.kernel.org>; Fri, 10 Aug 2007 10:17:42 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7A8HcNg006680
	for <netdev@vger.kernel.org>; Fri, 10 Aug 2007 10:17:39 +0200
In-Reply-To: <20070809.150014.32064726.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Friday 10 August 2007 00:00, David Miller wrote:
> From: Auke Kok <auke-jan.h.kok@intel.com>
> Date: Thu, 09 Aug 2007 09:41:17 -0700
> 
> > Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> 
> I think this is definitely how we should handle LRO
> configuration instead of the ad-hoc module parameters
> current LRO drivers use now.
> 
> I'll put this infrastructure into net-2.6.24, it would
> be nice if the EHEA and myri10g folks submitted conversions.
> 

yes, I'll submit a patch soon

