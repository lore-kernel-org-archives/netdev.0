From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 2/2] ipv6/udp: use sticky pktinfo egress ifindex
 on connect()
Date: Mon, 01 Feb 2016 18:18:22 -0800 (PST)
Message-ID: <20160201.181822.2097950091466572938.davem@davemloft.net>
References: <56AB5C37.7020604@stressinduktion.org>
	<56AEC187.1060308@miraclelinux.com>
	<56B00F17.7050007@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, hannes@stressinduktion.org,
	pabeni@redhat.com, netdev@vger.kernel.org, thehajime@gmail.com,
	lucien.xin@gmail.com, marcelo.leitner@gmail.com,
	yoshfuji@linux-ipv6.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45216 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbcBBCSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 21:18:23 -0500
In-Reply-To: <56B00F17.7050007@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 1 Feb 2016 19:06:15 -0700

> Can you queue these up for 4.4 stable? Fixes 'ping6 -I <interface>'
> for VRFs and 4.4 is the first release with VRF for IPv6.

Sure, done.
