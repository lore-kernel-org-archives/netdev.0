From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 -stable] Re: rib_trie / Fix inflate_threshold_root.
 Now=15 size=11 bits
Date: Tue, 07 Jul 2009 19:42:08 -0700 (PDT)
Message-ID: <20090707.194208.76202299.davem@davemloft.net>
References: <20090702060011.GB4954@ff.dom.local>
	<4A4FF34E.7080001@itcare.pl>
	<20090705130828.GB3094@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pstaszewski@itcare.pl, netdev@vger.kernel.org, robert@robur.slu.se,
	jorge@dti2.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58863
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758293AbZGHCmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 22:42:06 -0400
In-Reply-To: <20090705130828.GB3094@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 5 Jul 2009 15:08:28 +0200

> This new patch below is intended only for -stable (and later for
> net-next), because it doesn't meet rules of the current -rc. Anyway,
> it's not critical (but it actually fixes a regression from 2.6.22).

I think if we' re going to toss this into -stable, we should
put it into net-2.6 too, and that's what I'm going to do.

Once this makes it's way to Linus I'll work on the -stable
submissions.

And I'll make sure to add the tested-by tags, as you mentioned.

Thanks!
