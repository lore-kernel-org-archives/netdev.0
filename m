From: Andreas Mohr <andi@lisas.de>
Subject: Re: [Bugme-new] [Bug 14691] New: Complete NAPI IRQ lockup in b44
	driver: code fundamentally incompatible with netconsole requirements
Date: Mon, 30 Nov 2009 20:39:17 +0100
Message-ID: <20091130193917.GA8267@rhlx01.hs-esslingen.de>
References: <bug-14691-10286@http.bugzilla.kernel.org/> <20091125131631.46483ce0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net, Gary Zambrano <zambrano@broadcom.com>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	andi@lisas.de
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:35693 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753058AbZK3TjL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 14:39:11 -0500
Content-Disposition: inline
In-Reply-To: <20091125131631.46483ce0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improved patch created by David Miller (thanks!).
>From my POV, this can be considered handled.
http://lkml.org/lkml/2009/11/30/51
http://patchwork.kernel.org/patch/63627/

Andreas Mohr
