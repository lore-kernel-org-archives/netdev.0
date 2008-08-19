From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Re: 2.6.26/tg3 ping roundtrip times > 2000 ms on local network
Date: Wed, 20 Aug 2008 00:14:39 +0200
Message-ID: <20080819221439.GA19106@torres.zugschlus.de>
References: <20080819172019.GA5823@torres.zugschlus.de> <20080819.132040.188336475.davem@davemloft.net> <1219166962.13090.12.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	"mh+linux-kernel@zugschlus.de" <mh+linux-kernel@zugschlus.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	mcarlson@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.68.41]:51602 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752AbYHSWOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 18:14:41 -0400
Content-Disposition: inline
In-Reply-To: <1219166962.13090.12.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 10:29:22AM -0700, Michael Chan wrote:
> It has been fixed a few days ago in the net-2.6 tree:
> 
> tg3: Fix firmware event timeouts
> 
> and it should be in Linus' tree very soon.  This reminds us to send the
> same patch to -stable.

Not having much clue about git, can you send me the patch to try
locally?

I am not even sure to have a network issue here.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
