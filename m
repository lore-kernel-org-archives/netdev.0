From: Tino Keitel <tino.keitel@tikei.de>
Subject: Re: Regression: Wake on LAN doesn't work in sky2 with
 2.6.33-rc4-git2
Date: Tue, 19 Jan 2010 11:32:48 +0100
Message-ID: <20100119103248.GA8527@mac.home>
References: <20100115091053.GA5477@mac.home>
 <201001180136.45823.rjw@sisk.pl>
 <20100118083757.GA2619@mac.home>
 <201001182234.55113.rjw@sisk.pl>
 <20100118144340.100c9544@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:32849 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab0ASKcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 05:32:51 -0500
Received: from mac.home (port-92-206-67-99.dynamic.qsc.de [92.206.67.99])
	by eazy.amigager.de (Postfix) with ESMTPA id EC3CCC8C0D3
	for <netdev@vger.kernel.org>; Tue, 19 Jan 2010 11:32:49 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20100118144340.100c9544@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 18, 2010 at 14:43:40 -0800, Stephen Hemminger wrote:
> On Mon, 18 Jan 2010 22:34:55 +0100
> "Rafael J. Wysocki" <rjw@sisk.pl> wrote:

[...]

> > Perhaps we clear the WoL setting somewhere we shouldn't, but the
> > "disable PCI register writes" bit prevents this from actually happening?
> > 
> > Rafael
> 
> How about getting a register dump of pci config space with
> good/bad version?

At which point should the dump be placed? Somewhere as near to the              
actual suspend as possible?                                                     
                                                                                
Regards,                                                                        
Tino                                                                            
