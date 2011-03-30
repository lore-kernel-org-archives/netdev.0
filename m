From: Geert Hendrickx <geert@hendrickx.be>
Subject: Re: [Bug 28512] IPv6 SLAAC address preferred over static one as
 source address
Date: Wed, 30 Mar 2011 11:11:15 +0200
Message-ID: <20110330091115.GA8520@boris.ghen.be>
References: <bug-28512-25842@https.bugzilla.kernel.org/>
 <201103300900.p2U90PTc010650@demeter1.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: bugzilla-daemon@bugzilla.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from juliette.telenet-ops.be ([195.130.137.74]:60918 "EHLO
	juliette.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754552Ab1C3JLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 05:11:17 -0400
Content-Disposition: inline
In-Reply-To: <201103300900.p2U90PTc010650@demeter1.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2011 at 09:00:25 +0000, bugzilla-daemon@bugzilla.kernel.org wrote:
> The script posted at:
> 
> http://www.davidc.net/networking/ipv6-source-address-selection-linux
> 
> to mark the addresses as deprecated.


That requires you to know the SLAAC address (and thus the MAC address) in
advance, so not always applicable.  It's also no longer "stateless auto
configuration" if you have to hardcode the address in your startup config.


	Geert
 

-- 
geert.hendrickx.be :: geert@hendrickx.be :: PGP: 0xC4BB9E9F
This e-mail was composed using 100% recycled spam messages!
