From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2 -stable] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Wed, 8 Jul 2009 08:44:48 +0200
Message-ID: <20090708064448.GA3148@ami.dom.local>
References: <20090702060011.GB4954@ff.dom.local> <4A4FF34E.7080001@itcare.pl> <20090705130828.GB3094@ami.dom.local> <20090707.194208.76202299.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pstaszewski@itcare.pl, netdev@vger.kernel.org, robert@robur.slu.se,
	jorge@dti2.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:46521 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758630AbZGHGp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 02:45:26 -0400
Received: by bwz25 with SMTP id 25so2573045bwz.37
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2009 23:45:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090707.194208.76202299.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 07, 2009 at 07:42:08PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sun, 5 Jul 2009 15:08:28 +0200
> 
> > This new patch below is intended only for -stable (and later for
> > net-next), because it doesn't meet rules of the current -rc. Anyway,
> > it's not critical (but it actually fixes a regression from 2.6.22).
> 
> I think if we' re going to toss this into -stable, we should
> put it into net-2.6 too, and that's what I'm going to do.

It's your decision: I don't think this patch is worth any arguing
about (de)stabilizing. Btw., since -stable rules are less strict it
seems natural such patches with bug fixes should rather go net-next
-> -stable way, unless I miss something?

Thanks,
Jarek P.
