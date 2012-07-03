From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 6/7] qlge: refactoring of ethtool stats.
Date: Mon, 02 Jul 2012 18:26:32 -0700 (PDT)
Message-ID: <20120702.182632.261076908424205016.davem@davemloft.net>
References: <1341272514-5156-1-git-send-email-jitendra.kalsaria@qlogic.com>
	<1341272514-5156-7-git-send-email-jitendra.kalsaria@qlogic.com>
	<1341278648.2590.31.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jitendra.kalsaria@qlogic.com, netdev@vger.kernel.org,
	ron.mercer@qlogic.com, Dept_NX_Linux_NIC_Driver@qlogic.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756114Ab2GCB0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 21:26:33 -0400
In-Reply-To: <1341278648.2590.31.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 3 Jul 2012 02:24:08 +0100

> This is hardly an urgent fix...

This entire series is suspect, and largely inappropriate for 'net'
this late in the -rc.
