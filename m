From: Patrick McHardy <kaber@trash.net>
Subject: Re: hard hang through qdisc
Date: Thu, 31 Jan 2008 19:46:02 +0100
Message-ID: <47A2176A.7080606@trash.net>
References: <200801311321.01015.ak@suse.de> <47A1CD4E.7050701@trash.net> <47A1D4F2.6080904@trash.net> <200801311604.28110.ak@suse.de> <47A1E556.3050900@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56260 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758201AbYAaSqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:46:10 -0500
In-Reply-To: <47A1E556.3050900@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Andi Kleen wrote:
>
>> Can you please try with the above config?
> 
> 
> I'll give it a try later.


I took all options from that config that seemed possibly
related (qdiscs, no hrtimers, no nohz, slab, ...), but
still can't reproduce it.

Does it also crash if you use more reasonable parameters?

