From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25][NEIGH]: Add a comment describing what a NUD
 stands for.
Date: Thu, 10 Jan 2008 22:37:49 -0800 (PST)
Message-ID: <20080110.223749.42364096.davem@davemloft.net>
References: <47863435.3090407@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47981
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751402AbYAKGhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 01:37:50 -0500
In-Reply-To: <47863435.3090407@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 10 Jan 2008 18:05:25 +0300

> When I studied the neighbor code I puzzled over what
> the NUD can mean for quite a long time.
> 
> Finally I asked Alexey and he said that this was smth
> like "neighbor unreachability detection".
> 
> Does it worth adding a comment helping future developers 
> understand what's going on?
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

NUD is a common acronym in the IPV6 RFCs and various books
on the topic, but it doesn't hurt to add this comment so I
applied this patch thanks.
