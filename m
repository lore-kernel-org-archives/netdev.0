From: David Miller <davem@davemloft.net>
Subject: Re: scp stalls mysteriously
Date: Thu, 03 Dec 2009 02:34:31 -0800 (PST)
Message-ID: <20091203.023431.215087596.davem@davemloft.net>
References: <4B16BD58.3040802@tvk.rwth-aachen.de>
	<20091203085933.GD30730@sd-11162.dedibox.fr>
	<alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: fredo@starox.org, damian@tvk.rwth-aachen.de,
	netdev@vger.kernel.org, asdo@shiftmail.org, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, gregkh@suse.de
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48589
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752659AbZLCKeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 05:34:25 -0500
In-Reply-To: <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 3 Dec 2009 12:29:39 +0200 (EET)

> I've added Greg as CC to make him aware of this issue in early as it now 
> affects 2.6.32 too (rather important to get dealt quickly in stable once 
> we have a tested solution since TCP is pretty broken with the silent 
> deaths this problem seems to cause). ...One possibility would be to just 
> queue the tested revert to stable and sort this thing out for 2.6.33 in 
> net-2.6.

What revert?  Zero context provided here...
