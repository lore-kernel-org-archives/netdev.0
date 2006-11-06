From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: pktgen patch available for perusal.
Date: Mon, 6 Nov 2006 15:06:23 +0100
Message-ID: <17743.16735.391605.721451@robur.slu.se>
References: <45468F2E.4060809@candelatech.com>
	<17736.54766.657083.873206@robur.slu.se>
	<4548F166.1020001@candelatech.com>
	<1162643532.5166.34.camel@jzny2>
	<454CCDE0.5040109@candelatech.com>
	<1162663855.6237.116.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:62388 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S1753163AbWKFOGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 09:06:39 -0500
To: hadi@cyberus.ca
In-Reply-To: <1162663855.6237.116.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


jamal writes:

 > If you are listening then start with:
 > 
 > 1) Do a simple test with just udp traffic as above, doing simple
 > accounting. This helps you to get a feel on how things work.
 > 2) modify the matching rules to match your magic cookie
 > 3) write a simple action invoked by your matching rules and use tc to
 > add it to the policy.
 > 4) integrate in your app now that you know what you are doing.

 Yes. Sounds like simple and general solution. No call-backs, no #ifdef's
 no extra modules. Just a little recipe in pktgen.txt

 Cheers.
					--ro
 
