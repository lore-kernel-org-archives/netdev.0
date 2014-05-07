From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Wed, 07 May 2014 13:20:21 -0400 (EDT)
Message-ID: <20140507.132021.591444790908478214.davem@davemloft.net>
References: <20140505.232327.578134514220748085.davem@davemloft.net>
	<1399351148.8767.84.camel@empanada>
	<20140507145938.79110827@alan.etchedpixels.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom.zanussi@linux.intel.com, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: gnomes@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbaEGRUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 13:20:23 -0400
In-Reply-To: <20140507145938.79110827@alan.etchedpixels.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Date: Wed, 7 May 2014 14:59:38 +0100

> 16MB of DRAM means adding a chip to your system. You've just exceeded the
> space, power and cost budget on the very low end. In many cases like FPGA
> systems you can't even add DRAM without major hoop jumping.

A year or so for now this may not be true, which makes these kinds of changes
very nearly in the "point in time solution" category.

My main point in all of this is that whilst Linux should work on a braod range
of system types, there has to be a limit somewhere and I think 2MB is off
the deep end.
