From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Wed, 2 Oct 2013 00:20:02 +0200
Message-ID: <20131001222002.GL10771@order.stressinduktion.org>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34980 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964Ab3JAWUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 18:20:03 -0400
Content-Disposition: inline
In-Reply-To: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 01, 2013 at 06:39:32PM +0200, Wolfgang Walter wrote:
> All network traffic over the router become slow and sluggish. If one pings the 
> router there is a packet loss. After about 2 minutes the traffic completely 
> stalls for about 1 minute. Then it works again as in the beginning to then 
> stall again. And so on.

Maybe dropwatch can give a first hint?
