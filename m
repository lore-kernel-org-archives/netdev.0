From: Tino Keitel <tino.keitel@tikei.de>
Subject: Re: Regression: Wake on LAN doesn't work in sky2 with
 2.6.33-rc4-git2
Date: Mon, 18 Jan 2010 19:52:45 +0100
Message-ID: <20100118185245.GA3750@mac.home>
References: <20100115091053.GA5477@mac.home>
 <201001152323.37718.rjw@sisk.pl>
 <20100117231932.GA5504@mac.home>
 <201001180136.45823.rjw@sisk.pl>
 <20100118083757.GA2619@mac.home>
 <4B544D2C.8040400@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:53440 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755871Ab0ARSwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 13:52:49 -0500
Received: from mac.home (port-92-206-67-99.dynamic.qsc.de [92.206.67.99])
	by eazy.amigager.de (Postfix) with ESMTPA id 6D307C8C10A
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 19:52:48 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <4B544D2C.8040400@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 18, 2010 at 20:59:40 +0900, Mike McCormack wrote:
> Tino Keitel wrote:
> > Hi,
> > 
> > reverting this commit fixes WoL for me:
> > 
> > commit 166a0fd4c788ec7f10ca8194ec6d526afa12db75
> 
> Hi Tino,
> 
> Does this fix WoL also?  Compile tested only...

No, still no wakeup on WoL packets.

Regards,
Tino
