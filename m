From: David Miller <davem@davemloft.net>
Subject: Re: [0/4] trivial cleanups for via-velocity.c
Date: Tue, 21 Jul 2009 11:12:35 -0700 (PDT)
Message-ID: <20090721.111235.211304996.davem@davemloft.net>
References: <200907211640.n6LGeG5d011439@gelk.kernelslacker.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52421
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751973AbZGUSMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 14:12:30 -0400
In-Reply-To: <200907211640.n6LGeG5d011439@gelk.kernelslacker.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 20 Jul 2009 23:34:56 -0400

> I've had these sitting around for a while, they should be safe to apply.
> I checked a diff of the disassembly from objdump before/after, and
> the only diffs were the placement of the functions & jump offsets changing
> due to the reordering in diff 3/4.

These do not apply to the driver in the current tree, particularly
it doesn't apply at all to net-next-2.6 which is where I would
add this.

Please fix this up and resubmit, thanks.
