From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 28512] IPv6 SLAAC address preferred over static one as
 source address
Date: Wed, 30 Mar 2011 02:13:01 -0700 (PDT)
Message-ID: <20110330.021301.191408290.davem@davemloft.net>
References: <bug-28512-25842@https.bugzilla.kernel.org/>
	<201103300900.p2U90PTc010650@demeter1.kernel.org>
	<20110330091115.GA8520@boris.ghen.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: geert@hendrickx.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42325
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754906Ab1C3JNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 05:13:38 -0400
In-Reply-To: <20110330091115.GA8520@boris.ghen.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Hendrickx <geert@hendrickx.be>
Date: Wed, 30 Mar 2011 11:11:15 +0200

> On Wed, Mar 30, 2011 at 09:00:25 +0000, bugzilla-daemon@bugzilla.kernel.org wrote:
>> The script posted at:
>> 
>> http://www.davidc.net/networking/ipv6-source-address-selection-linux
>> 
>> to mark the addresses as deprecated.
> 
> That requires you to know the SLAAC address (and thus the MAC address) in
> advance, so not always applicable.  It's also no longer "stateless auto
> configuration" if you have to hardcode the address in your startup config.

I said there was an existing workaround, I did not say it was perfect.

And in that context it's reasonable for me to require real guidance
from the IETF before we make a change.

