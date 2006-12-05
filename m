From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] atm: Add CPPFLAGS to byteorder.h check
Date: Mon, 04 Dec 2006 19:34:02 -0800 (PST)
Message-ID: <20061204.193402.45179856.davem@davemloft.net>
References: <200612042306.kB4N6haQ008125@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcollins@ubuntu.com, chas@cmf.nrl.navy.mil,
	jeff@garzik.org, sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47107
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S968059AbWLEDeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 22:34:00 -0500
To: akpm@osdl.org
In-Reply-To: <200612042306.kB4N6haQ008125@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Mon, 04 Dec 2006 15:05:34 -0800

> From: Ben Collins <bcollins@ubuntu.com>
> 
> O= builds produced errors in the shell command because of unfound headers.
> 
> Signed-off-by: Ben Collins <bcollins@ubuntu.com>
> Cc: chas williams <chas@cmf.nrl.navy.mil>
> Cc: Sam Ravnborg <sam@ravnborg.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

I've applied this.
