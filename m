From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] mac80211: Ensure initializing private mc_list in
 prepare_multicast().
Date: Tue, 6 Apr 2010 09:17:46 +0200
Message-ID: <20100406071745.GF2869@psychotron.redhat.com>
References: <201004050457.o354v6ec008492@94.43.138.210.xn.2iij.net>
 <20100406070922.GE2869@psychotron.redhat.com>
 <20100406.001259.15002237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12130 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757280Ab0DFHR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Apr 2010 03:17:56 -0400
Content-Disposition: inline
In-Reply-To: <20100406.001259.15002237.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Apr 06, 2010 at 09:12:59AM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Tue, 6 Apr 2010 09:09:23 +0200
>
>> Whoups, missed this bit. Thanks a lot.
>> 
>> Rewieved-by: Jiri Pirko <jpirko@redhat.com>
>> 
>
>Applied, and patchwork doesn't know what "Rewieved-by" is so
>I fixed the typo and added it to the changelog :-)

Oh my :) Looks like I'm still sleeping...
