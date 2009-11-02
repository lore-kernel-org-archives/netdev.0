From: Sergei Poselenov <sposelenov@emcraft.com>
Subject: Re: Patch: Fix userland build failure in linux/if_tunnel.h
Date: Mon, 2 Nov 2009 13:57:50 +0300
Message-ID: <20091102135750.436a7b54@emcraft.com>
References: <4AEDCBA6.7040206@dresearch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sledz@dresearch.de, wd@denx.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Steffen Sledz <sledz@dresearch.de>,
	Steffen Sledz <sledz@zone42.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ocean.emcraft.com ([213.221.7.182]:45430 "EHLO
	ocean.emcraft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754497AbZKBLQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 06:16:33 -0500
In-Reply-To: <4AEDCBA6.7040206@dresearch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Steffen,

Hm, I received a confirmation, that my fix was applied
http://www.spinics.net/lists/netdev/msg103860.html

However, it indeed didn't find their way into the mainline.
I have no idea why, received no objections.

I'm sending the reply to the resp. mailing lists too; hope you don't
mind.

Regards,
Sergei

On Sun, 01 Nov 2009 18:55:50 +0100
Steffen Sledz <sledz@dresearch.de> wrote:

> Hello Sergei,
> 
> i'm working for the OpenEmbedded project and we hit the same busybox
> problem you mentioned in <http://patchwork.kernel.org/patch/31164/>.
> 
> It doesn't look like you got much feedback on you patch suggestion.
> Did it made it's way to the kernel sources? Or where there any
> objections on it?
> 
> Steffen

