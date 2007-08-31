From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE] iproute2-2.6.23-rc3
Date: Fri, 31 Aug 2007 11:10:24 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708311109590.5358@x2>
References: <20070822110804.30c2e803@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53348 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755721AbXHaJLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 05:11:35 -0400
In-Reply-To: <20070822110804.30c2e803@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Aug 2007, Stephen Hemminger wrote:

> There have been a lot of changes for 2.6.23, so here is a test release
> of iproute2 that should capture all the submitted patches
>
> Patrick McHardy (6):
>      TC action parsing bug fix
>      Bug fix tc action drop
>      IPROUTE2: RTNETLINK nested attributes
>      Use FRA_* attributes for routing rules
>      iplink: use netlink for link configuration
>      Fix meta ematch usage of 0 values


I just noticed the iplink_vlan stuff is missing. Do you want me
to resend?

