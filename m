From: Reinhard Max <max@suse.de>
Subject: Re: net/ipv4: commit d0733d2e29b breaks rtorrent
Date: Wed, 22 Jun 2011 15:24:53 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1106221508310.10066@nitsch.suse.de>
References: <20110622124045.GA3247@localhost> <20110622124727.GC19184@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Fabienne Ducroquet <fabiduc@gmail.com>, sundell.software@gmail.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Marcus Meissner <meissner@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41086 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757913Ab1FVNYz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 09:24:55 -0400
In-Reply-To: <20110622124727.GC19184@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 22 Jun 2011 at 14:47, Marcus Meissner wrote:

> Can you show us the code surrounding the bind in rtorrent?

... or short of that, the output of "strace -e socket,bind" when 
starting rtorrent with the kernel patch not reverted?


cu
 	Reinhard
