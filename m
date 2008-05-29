From: James Cammarata <jimi@sngx.net>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool - e1000/pcnet32
Date: Thu, 29 May 2008 16:18:03 -0500
Message-ID: <483F1D8B.7010904@sngx.net>
References: <483EA2D1.8050603@sngx.net>	<20080529154525.3916c7b5@core>	<483EE4A4.20508@sngx.net> <20080529.135055.193706538.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl093-193-175.stl1.dsl.speakeasy.net ([66.93.193.175]:58240
	"EHLO hades.sngx.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752889AbYE2VSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 17:18:38 -0400
In-Reply-To: <20080529.135055.193706538.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>  I'd be more than happy to change this to a kernel config
>> option, experimental and default off for those who would not want it.
> 
> We never add pieces of code which are marked experimental and
> intended to be marked that way forever, that's nonsense.

Completely not my intention, I did not ever intend to have something
marked experimental forever, and I'm not sure where you're drawing
that inference from.
 
> What you want is your little special kernel hack in the upstream
> tree, and that's now how we handle such things, sorry.

No, I saw what I thought was a lack of a feature that is commonplace 
on many other platforms, and thought I'd give it a shot to see if 
I could add it myself.  The NAKs are apparently overwhelming on this
issue, so I'll stop beating a dead horse and move on.  Thanks for the 
input.
