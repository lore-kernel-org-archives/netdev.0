From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 9/9] Add explicit bound checks in net/socket.c
Date: Sat, 26 Sep 2009 23:35:38 +0400
Message-ID: <20090926193538.GC4356@lenovo>
References: <20090926204951.424e567e@infradead.org> <20090926205432.24aa1023@infradead.org> <20090926190103.GB4356@lenovo> <20090926212302.0ce64a5c@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	mingo@elte.hu, netdev@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f211.google.com ([209.85.219.211]:51424 "EHLO
	mail-ew0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867AbZIZTfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2009 15:35:36 -0400
Content-Disposition: inline
In-Reply-To: <20090926212302.0ce64a5c@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Arjan van de Ven - Sat, Sep 26, 2009 at 09:23:02PM +0200]
...
| 
| goof once goof twice, make it sizeof.. that's nicer.
| 

yeah, I was about to propose the same :)

...
	- Cyrill
