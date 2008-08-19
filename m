From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 23:15:47 +0200
Message-ID: <200808192315.48718.rjw@sisk.pl>
References: <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org> <alpine.LFD.1.10.0808191341150.3324@nehalem.linux-foundation.org> <20080819.140458.236030589.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:55018 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753070AbYHSVMK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 17:12:10 -0400
In-Reply-To: <20080819.140458.236030589.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, 19 of August 2008, David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Tue, 19 Aug 2008 13:47:59 -0700 (PDT)
> 
> > Same goes for all the loopback changes. They look like cleanups or feature 
> > enables.
> 
> Those fix a performance regression reported by a real user.

FWIW, they fix the recent regression tracked as
http://bugzilla.kernel.org/show_bug.cgi?id=11316 .

Thanks,
Rafael
