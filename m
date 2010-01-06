From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [net-next PATCH] net: RFC3069, private VLAN proxy arp support
Date: Wed, 06 Jan 2010 19:59:43 +0100
Message-ID: <4B44DD9F.4020807@computer.org>
References: <20100105155047.13309.79610.stgit@firesoul.comx.local>	<4B4427CE.1040203@gmail.com>	<1262771369.9474.80.camel@jdb-workstation> <20100106232231.5f454d53@opy.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hawk@comx.dk, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:50091 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932620Ab0AFTE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 14:04:27 -0500
In-Reply-To: <20100106232231.5f454d53@opy.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Smith wrote:
> I can see value in that - you're forcing all traffic through the
> upstream router for policy enforcement purposes, without having to have
> point-to-point (simulated or otherwise) links between customers and the
> router, and avoiding IP address waste by not using /30s. You're pretty
> much making the ethernet a Non-broadcast Multi-Access link.

Similar to what DSLAMs do...

Jan
