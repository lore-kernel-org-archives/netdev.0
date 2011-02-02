From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v4 0/2] iproute2: support for device groups
Date: Thu, 03 Feb 2011 00:01:38 +0100
Message-ID: <4D49E252.1080006@trash.net>
References: <1296671021-24421-1-git-send-email-ddvlad@rosedu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44561 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755268Ab1BBXBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:01:39 -0500
In-Reply-To: <1296671021-24421-1-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 02.02.2011 19:23, schrieb Vlad Dogaru:
> This patch series adds userspace support for network device groups.
> There is support for setting device groups, listing only interfaces of a
> specific group, and setting basic device parameters for all interfaces
> in a group.
> 
> Changes since version 3:
>  * drop devgroup keyword. There is a single keyword for specifying
>    groups now.
>  * store group names internally as a hash, similar to routing table
>    names. This is more efficient for batch mode operations

Looks good to me, thanks.
