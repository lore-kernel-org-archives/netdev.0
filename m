From: David Miller <davem@davemloft.net>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Wed, 27 Aug 2008 14:29:41 -0700 (PDT)
Message-ID: <20080827.142941.50104491.davem@davemloft.net>
References: <200808261549.m7QFnVUN032543@bz-web1.app.phx.redhat.com>
	<20080826163719.GA25066@redhat.com>
	<87zlmyr5nz.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org, j.w.r.degoede@hhs.nl
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59468
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752095AbYH0V3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 17:29:46 -0400
In-Reply-To: <87zlmyr5nz.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 27 Aug 2008 14:41:52 +0200

> Dave Jones <davej@redhat.com> writes:
> 
> > Just had this bug reported against our development tree..
> 
> SUSE had an old patch for this which unfortunately got rejected 
> some time ago for some bogus reason.

Really, your patch fixes this specific slowdown that got introduced
recently?  I really doubt it Andi, so please don't use this as an
opportunity to toot your own horn, thanks.
