From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 16:45:36 +0100
Message-ID: <20080424164536.4717afb7@the-village.bc.nu>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
	<20080424112514.055d8071@the-village.bc.nu>
	<481096C3.2020206@redhat.com>
	<20080424152436.6cf53c1b@the-village.bc.nu>
	<4810A46B.1090809@redhat.com>
	<20080424160352.30f2dd5b@the-village.bc.nu>
	<4810AB29.5030604@redhat.com>
	<20080424162703.1eec01a2@the-village.bc.nu>
	<4810AF9F.5040705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:55359 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754694AbYDXQOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 12:14:34 -0400
In-Reply-To: <4810AF9F.5040705@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Once again, this is not about assigned values.  This is about the time
> before you get a value assigned.  Not every experiment out there will
> have a value assigned before it starts development.

And no value used by a random experiment on the internet belongs in any
one elses code. When it hits the kernel main tree it becomes definitive
and will remain so. Until then it remains someones devel hack.

The same is true about syscall numbers so your argument on this is
slightly less than sound.

