From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] udp: Don't save dst in udpv6_sendmsg()
Date: Sat, 24 Oct 2009 06:40:10 -0700 (PDT)
Message-ID: <20091024.064010.145864194.davem@davemloft.net>
References: <20091023111336.4733.4901.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55543
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753429AbZJXNjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 09:39:47 -0400
In-Reply-To: <20091023111336.4733.4901.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Fri, 23 Oct 2009 16:43:36 +0530

> Performance: I ran netperf UDPv6 RR to use connected sockets.
> Tested with a 70 min run, aggregate of 5 netperf runs for
> each result.

Who actually uses connected UDP sockets? :-)
