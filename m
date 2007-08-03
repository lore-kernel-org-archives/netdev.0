From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] lro: myri10ge example how to use LRO
Date: Fri, 03 Aug 2007 13:30:27 -0700
Message-ID: <46B39063.6070301@intel.com>
References: <46B363A8.4010407@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raisch@de.ibm.com, themann@de.ibm.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	meder@de.ibm.com, tklein@de.ibm.com, stefan.roscher@de.ibm.com,
	jeff@garzik.org, davem@davemloft.net
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37468 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760326AbXHCUaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 16:30:30 -0400
In-Reply-To: <46B363A8.4010407@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Gallatin wrote:
> To follow up on Jan-Bernd Themann's LRO patch earlier today,
> this patch shows how the generic LRO interface can be used for
> page based drivers.
> 
> Again, many thanks to Jan-Bernd Themann for leading this effort.
> 
> Drew
> 
> Singed off by: Andrew Gallatin <gallatin@myri.com>
> 


please take a look at my lro patch for ethtool and see if it works for you, 
instead of adding another generic module parameter that doesn't need to be there.

Thanks.

Auke
