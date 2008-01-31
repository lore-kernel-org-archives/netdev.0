From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 19:33:22 +0100
Message-ID: <20080131183322.GA4671@one.firstfloor.org>
References: <20080131124632.GA25299@basil.nowhere.org> <20080131092327.75b9c369@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:36911 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756532AbYAaR65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 12:58:57 -0500
Content-Disposition: inline
In-Reply-To: <20080131092327.75b9c369@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Fix the broken qdisc instead.

What do you mean? I don't think the qdiscs are broken.
I cannot think of any way how e.g. TBF can do anything useful
with large TSO packets.

-Andi
