From: Patrick McHardy <kaber@trash.net>
Subject: Re: Repost: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Wed, 12 Jul 2006 08:50:07 +0200
Message-ID: <44B49B9F.6050501@trash.net>
References: <200603211829.k2LITMNR029085@hera.kernel.org> <200607071145.09325.stefan@loplof.de> <44AE2FCC.6020207@trash.net> <200607120015.17735.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48565 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750750AbWGLGuJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 02:50:09 -0400
To: Stefan Rompf <stefan@loplof.de>
In-Reply-To: <200607120015.17735.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stefan Rompf wrote:
> the following patch should fix the problem. Patrick, can you give it a
> try? As the bug did not affect me through my testing, I want to be sure it
> works now. This is stuff for 2.6.18 and 2.6.17-stable.

I'm on my way out the door and will be gone for a couple of days,
so its going to take me a while. But it looks fine, if you want
to test it yourself, just pull the ethernet cable before adding
a VLAN and plug it in again afterwards.

