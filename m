From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26][VLAN]: Reduce memory consumed by vlan_group-s.
Date: Wed, 26 Mar 2008 16:39:25 +0100
Message-ID: <47EA6E2D.5000101@trash.net>
References: <47CC2ACF.6080903@openvz.org> <47E2731A.3090401@trash.net> <47EA67C7.1050202@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33250 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684AbYCZPj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 11:39:28 -0400
In-Reply-To: <47EA67C7.1050202@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> Hi, Patrick.
> 
>> Its an improvement, so I've applied it, thanks.
> 
> I noticed you merged some netfilter patches to net-2.6.26, but what 
> are your plans about merging vlan-related patches to it? 
> 
> I ask because I have some patches with vlan netnsization, but I can't
> just send them to net-2.6.26, since they will produce conflicts with 
> this patch and maybe more you have for vlan, which are not at Dave yet.
> 

I have some unfinished patches so I didn't send it yet, but I'll
push just this patch to Dave later today so you can merge your
work.
