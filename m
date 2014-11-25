From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_tunnel: the lack of vti_link_ops' dellink() cause
 kernel panic
Date: Tue, 25 Nov 2014 01:08:39 -0500 (EST)
Message-ID: <20141125.010839.907618384855778659.davem@davemloft.net>
References: <1416726251-13088-1-git-send-email-lucien.xin@gmail.com>
	<54733E3E.7070702@6wind.com>
	<CADvbK_f31zM4B97r29jZuEE_fRbZY55SEWifjAFWg86wrfVFDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	steffen.klassert@secunet.com, cwang@twopensource.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58256 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbaKYGIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 01:08:41 -0500
In-Reply-To: <CADvbK_f31zM4B97r29jZuEE_fRbZY55SEWifjAFWg86wrfVFDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lucien xin <lucien.xin@gmail.com>
Date: Tue, 25 Nov 2014 13:53:15 +0800

>> Nitpicking: please, use a tab instead of space to align the '=', like other
>> lines.
> 
> ok, I will repost it.

That's pointless, as I already applied your original patch to
my tree.
