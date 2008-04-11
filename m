From: Patrick McHardy <kaber@trash.net>
Subject: Re: Re-queueing of skb in vlan_skb_recv
Date: Fri, 11 Apr 2008 18:16:48 +0200
Message-ID: <47FF8EF0.4040304@trash.net>
References: <8A9D56C5E50F774BABE033F1710B357601084C42@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>	<47FF5DAB.1060906@trash.net>	<1207918405.22152.97.camel@ragnarok>	<47FF616F.6090309@trash.net> <20080411084402.7c8abf37@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeremy Jackson <jerj@coplanar.net>,
	Brian Oostenbrink <Brian_Oostenbrink@pmc-sierra.com>,
	linux-net@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58478 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758822AbYDKQQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 12:16:55 -0400
In-Reply-To: <20080411084402.7c8abf37@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Fri, 11 Apr 2008 15:02:39 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> Jeremy Jackson wrote:
>>> There was a patch floating around fixing VLAN + Bridge, I'm wondering if
>>> it got any traction (ie merged), or if this would affect future merge of
>>> that feature?
 >>>
>> Whats broken with VLAN + Bridge? Do you have a pointer to
>> this patch?

> This is sitting in my to be examined queue...
> 
> Subject: Re: [Bridge] [PATCH] Add vlan id to bridge forward database


Thanks for the pointer, I'll try to have a closer look this weekend.
