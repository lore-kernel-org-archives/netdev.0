From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] vlan: propogate MTU changes (v2)
Date: Tue, 07 Oct 2008 00:53:33 +0200
Message-ID: <48EA96ED.7060901@trash.net>
References: <20081006173024.2741cc01@speedy>	<48EA369F.3090306@trash.net>	<20081006195446.1dc5a372@speedy> <20081006202554.11354b09@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56612 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453AbYJFWxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 18:53:40 -0400
In-Reply-To: <20081006202554.11354b09@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Propogate MTU changes of underlying device to all VLAN's and
> send vlan MTU change out to userspace.
> 
> see: https://bugzilla.vyatta.com/show_bug.cgi?id=3742

This really doesn't answer any of the questions related to this
change, mainly whether this kind of behaviour shouldn't be
user controllable.
