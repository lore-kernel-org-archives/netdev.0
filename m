From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: net_rx_action/NAPI oops [PATCH]
Date: Wed, 28 Nov 2007 13:36:31 +0100
Message-ID: <18253.24783.174884.502970@robur.slu.se>
References: <18252.26472.319078.165019@robur.slu.se>
	<20071127140904.20c4cba8@freepuppy.rosehill>
	<474C9B84.5090103@intel.com>
	<20071127145537.6bf1af68@freepuppy.rosehill>
	<474CB54A.2060804@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:37658 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751458AbXK1Mgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 07:36:43 -0500
In-Reply-To: <474CB54A.2060804@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Kok, Auke writes:
 > 
 > Robert, please give that patch a try (it fixes a crash that I had here as well)
 > and let us know if it works for you.

 No it doesn't cure the problem I've reported

 Cheers.
						--ro


 BTW. You can try to verify the problem... Let pktgen feed a couple of streams
 into some interfaces. (I use two) ifconfig down sone of the incoming interfaces....
