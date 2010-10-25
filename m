From: David Miller <davem@davemloft.net>
Subject: Re: [Security] TIPC security issues
Date: Sun, 24 Oct 2010 22:28:38 -0700 (PDT)
Message-ID: <20101024.222838.104033980.davem@davemloft.net>
References: <AANLkTi=V93A660+YS8C2TvC13kGUcJpFgjPHUvONd_WW@mail.gmail.com>
	<20101024.191415.226787411.davem@davemloft.net>
	<AANLkTinXmKrf+wovco0j_aBuB7=qSq42+bVCM-amfL7W@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drosenberg@vsecurity.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, netdev@vger.kernel.org,
	security@kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41381
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751296Ab0JYF2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 01:28:15 -0400
In-Reply-To: <AANLkTinXmKrf+wovco0j_aBuB7=qSq42+bVCM-amfL7W@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 24 Oct 2010 20:42:39 -0700

> David - the issue is _security_. The way to fix security problems is
> not to say "most things handle this correctly". The way to avoid them
> is to have several layers of handling things correctly, so that even
> when one turns out to be broken, the others still protect it.

Fair enough.
