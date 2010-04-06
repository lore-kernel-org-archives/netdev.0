From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac80211: Ensure initializing private mc_list in
 prepare_multicast().
Date: Tue, 06 Apr 2010 00:12:59 -0700 (PDT)
Message-ID: <20100406.001259.15002237.davem@davemloft.net>
References: <201004050457.o354v6ec008492@94.43.138.210.xn.2iij.net>
	<20100406070922.GE2869@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37933
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755877Ab0DFHM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 03:12:57 -0400
In-Reply-To: <20100406070922.GE2869@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 6 Apr 2010 09:09:23 +0200

> Whoups, missed this bit. Thanks a lot.
> 
> Rewieved-by: Jiri Pirko <jpirko@redhat.com>
> 

Applied, and patchwork doesn't know what "Rewieved-by" is so
I fixed the typo and added it to the changelog :-)
