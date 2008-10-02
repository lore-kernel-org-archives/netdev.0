From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 28/33] netns nat: fix ipt_MASQUERADE in netns
Date: Thu, 02 Oct 2008 11:06:17 +0200
Message-ID: <48E48F09.5070004@trash.net>
References: <48C01046.2070704@trash.net> <1220842990-30500-28-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52366 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752841AbYJBJHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 05:07:19 -0400
In-Reply-To: <1220842990-30500-28-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> First, allow entry in notifier hook.
> Second, start conntrack cleanup in netns to which netdevice belongs.

Applied.
