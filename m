From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] PPPoE: miscellaneous smaller cleanups
Date: Fri, 20 Apr 2007 16:56:49 -0700 (PDT)
Message-ID: <20070420.165649.116963863.davem@davemloft.net>
References: <11737949753580-git-send-email-mostrows@earthlink.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mostrows@watson.ibm.com, netdev@vger.kernel.org, florz@florz.de
To: mostrows@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45916
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752250AbXDTX4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 19:56:46 -0400
In-Reply-To: <11737949753580-git-send-email-mostrows@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Ostrowski <mostrows@earthlink.net>
Date: Tue, 13 Mar 2007 09:09:32 -0500

> below is a patch that just removes dead code/initializers without any
> effect (first access is an assignment) that I stumbled accross while
> reading the source.
> 
> Signed-off-by: Florian Zumbiehl <florz@florz.de>
> Acked-by: Michal Ostrowski <mostrows@earthlink.net>

I munged this patch into net-2.6.22, thanks!
