From: David Miller <davem@davemloft.net>
Subject: Re: [next-next PATCH] e1000e: fixup merge error
Date: Fri, 20 Mar 2009 15:56:44 -0700 (PDT)
Message-ID: <20090320.155644.86516049.davem@davemloft.net>
References: <20090320.013141.243957487.davem@davemloft.net>
	<20090320152447.GA28023@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, Arthur.Jones@riverbed.com, shemminger@vyatta.com,
	alexander.h.duyck@intel.com
To: ajones@riverbed.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56755
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751731AbZCTW45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 18:56:57 -0400
In-Reply-To: <20090320152447.GA28023@ajones-laptop.nbttech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arthur Jones <ajones@riverbed.com>
Date: Fri, 20 Mar 2009 08:24:47 -0700

> When merging into Jeff's tree:
> 
> 	commit 5f66f208064f083aab5e55935d0575892e033b59
> 	Author: Arthur Jones <ajones@riverbed.com>
> 	Date:   Thu Mar 19 01:13:08 2009 +0000
> 
> 	    e1000e: allow tx of pre-formatted vlan tagged packets
> 
> We lost one line, this fixes that missing
> piece...
> 
> Signed-off-by: Arthur Jones <ajones@riverbed.com>

Applied, thanks Arthur.
