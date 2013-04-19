From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v5 1/1] net: fec: Enable imx6 enet checksum
 acceleration.
Date: Fri, 19 Apr 2013 19:50:44 +0100
Message-ID: <1366397444.2716.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <Jim Baxter <jim_baxter@mentor.com>
	 <1366395049-5417-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, <netdev@vger.kernel.org>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13680 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472Ab3DSSut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 14:50:49 -0400
In-Reply-To: <1366395049-5417-1-git-send-email-jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 19:10 +0100, Jim Baxter wrote:
> Enables hardware generation of IP header and
> protocol specific checksums for transmitted
> packets.
> 
> Enabled hardware discarding of received packets with
> invalid IP header or protocol specific checksums.
> 
> The feature is enabled by default but can be
> enabled/disabled by ethtool.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
