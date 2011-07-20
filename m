From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in	ndo_start_xmit
 methods
Date: Tue, 19 Jul 2011 17:25:00 -0700
Message-ID: <4E26205C.1040106@hp.com>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>	<1311105738.3113.11.camel@edumazet-laptop>	<20110719202922.GA2352@minipsycho>	<1311108107.3113.22.camel@edumazet-laptop> <20110720001904.GA1992@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:6437 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab1GTAZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 20:25:03 -0400
In-Reply-To: <20110720001904.GA1992@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How "everyday use" is pktgen considered?  As "everyday use" as 
netperf/iperf/whatnot? Is it actually considered something one would run 
on production rather than test systems?

rick jones
