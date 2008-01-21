From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] atm/idt77105.c: fix section mismatch
Date: Sun, 20 Jan 2008 17:22:37 -0800 (PST)
Message-ID: <20080120.172237.107308330.davem@davemloft.net>
References: <20080119131849.GA8669@does.not.exist>
	<20080119132852.GB26615@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, chas@cmf.nrl.navy.mil, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47527
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756439AbYAUBWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 20:22:32 -0500
In-Reply-To: <20080119132852.GB26615@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Ravnborg <sam@ravnborg.org>
Date: Sat, 19 Jan 2008 14:28:52 +0100

> On Sat, Jan 19, 2008 at 03:18:49PM +0200, Adrian Bunk wrote:
> > EXPORT_SYMBOL'ed code mustn't be __*init.
> > 
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> Acked-by: Sam Ravnborg <sam@ravnborg.org>

Applied.
