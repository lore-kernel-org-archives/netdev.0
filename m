From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 0/6] net: mvpp2: Assorted fixes
Date: Wed, 23 Jul 2014 00:29:16 +0200
Message-ID: <20140723002916.67a0bb3c@free-electrons.com>
References: <1405961296-5846-1-git-send-email-ezequiel.garcia@free-electrons.com>
	<20140721.202749.913689946944612851.davem@davemloft.net>
	<20140722144519.GA682@arch.cereza>
	<20140722.131639.1180592286226896307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ezequiel.garcia@free-electrons.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jason@lakedaemon.net,
	mw@semihalf.com, gregory.clement@free-electrons.com,
	tawfik@marvell.com, alior@marvell.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:36901 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932722AbaGVW3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 18:29:20 -0400
In-Reply-To: <20140722.131639.1180592286226896307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David Miller,

On Tue, 22 Jul 2014 13:16:39 -0700 (PDT), David Miller wrote:

> >> This series does not apply to the 'net' tree at all, please respin
> >> and resubmit.
> > 
> > This series applies on net-next.
> > 
> > Sorry for not mentioning it,
> 
> They are bonafide bug fixes, therefore should be targetted at 'net'.

Except that I believe they are fixes for a driver which itself is in
net-next, i.e scheduled for 3.17.

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
