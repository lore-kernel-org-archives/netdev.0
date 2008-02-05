From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 16:03:01 +0000
Message-ID: <20080205160301.7b2369ee@core>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com>
	<20080205155558.GA23145@one.firstfloor.org>
	<20080205154213.059ac6e8@core>
	<20080205163912.GB23145@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Glenn Griffin <ggriffin.kernel@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:58137 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752442AbYBEQIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 11:08:43 -0500
In-Reply-To: <20080205163912.GB23145@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Also your sub PC class appliances rarely run LISTEN servers anyways
> that are open to the world.

Really. The ones that first come to mind often have exposed ports
including PDA devices and phones. (Ditto low end PC boxes - portscan an
EEPC some day ;))

Is the other stuff enough - good question, and can be measured easily
enough on a little dlink router or similar.

Alan
