From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Mon, 01 Jun 2009 14:32:48 -0700 (PDT)
Message-ID: <20090601.143248.258478440.davem@davemloft.net>
References: <20090601.032500.54712490.davem@davemloft.net>
	<1243867942.3015.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45199
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750819AbZFAVcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 17:32:48 -0400
In-Reply-To: <1243867942.3015.18.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Mon, 01 Jun 2009 16:52:21 +0200

>> Things are really winding down, and the bug fix rate is down
>> to at best a trickle.  It might be time to do that final
>> release soon :-)
> 
> can you give me quick update on this pull request:
> 
> 	http://marc.info/?l=linux-netdev&m=124341070008320&w=2

Sorry that I overlooked this.

Unfortunately, I almost entirely use patchwork to manage my
work queue.  So if you're pull request doesn't attach a patch
it's possible that it'll get lost in my inbox.  So I suggest
attaching a patch to your pull requests, at least for bug
fix work, just like John Linville does for wireless.

That also let's me quickly review your work in-place in my
mailbox before I even type the git pull command, which helps
me a lot.

Anyways, I've pulled in your tree, thanks.
