From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 18/18] flag parameters: check magic constants
Date: Mon, 12 May 2008 21:02:25 -0700 (PDT)
Message-ID: <20080512.210225.167924945.davem@davemloft.net>
References: <200805062118.m46LI74j004096@devserv.devel.redhat.com>
	<20080512201341.9ead6a9a.akpm@linux-foundation.org>
	<482910FA.1080703@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: drepper@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60007
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750986AbYEMECb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 00:02:31 -0400
In-Reply-To: <482910FA.1080703@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Drepper <drepper@redhat.com>
Date: Mon, 12 May 2008 20:54:34 -0700

> This has no costs on platforms other than alpha.
> 
> Shall I sent a patch?

You'll need to handle MIPS and PARISC as well, as they have
similar conflicts.
