From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Mon, 30 Dec 2013 19:52:09 -0500 (EST)
Message-ID: <20131230.195209.1342950946997239413.davem@davemloft.net>
References: <20131229.230224.1652891996387193020.davem@davemloft.net>
	<CAJZOPZLciJ=X9_h9eqd0KrdkrOT6tKw93wFnmDKY6cQfG_4ZTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com, weichunc@plumgrid.com
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932365Ab3LaAwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 19:52:12 -0500
In-Reply-To: <CAJZOPZLciJ=X9_h9eqd0KrdkrOT6tKw93wFnmDKY6cQfG_4ZTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Mon, 30 Dec 2013 14:50:09 +0200

> On Mon, Dec 30, 2013 at 6:02 AM, David Miller <davem@davemloft.net> wrote:
> 
>> Some holiday bug fixes for 3.13... There is still one bug I'd like to get fixed
>> before 3.13-final.
> 
> Hi Dave,
> 
> Just wanted to check with you re this fix which makes hw offloaded
> vxlan gso traffic from VMs to actually work...
> http://patchwork.ozlabs.org/patch/303025
> I would say we really want it for 3.13 and after spending some time
> there into -stable down to 3.10.y where the offloaded gso was
> introduced - makes sense?

Alternative ways to fix the problem were being discussed and therefore
the patch is in "Changes Requested" state, so you shouldn't be
expecting me to apply it.

If the discussion winds down to making no changes at all, the patch
should be resubmitted freshly.
