From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 1/1] net: fec: Enable imx6 enet checksum
 acceleration.
Date: Thu, 25 Apr 2013 03:59:37 -0400 (EDT)
Message-ID: <20130425.035937.7194163505269817.davem@davemloft.net>
References: <Jim_Baxter_<jim_baxter@mentor.com>
	<1366395049-5417-1-git-send-email-jim_baxter@mentor.com>
	<1366397444.2716.8.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jim_baxter@mentor.com, fabio.estevam@freescale.com,
	Frank.Li@freescale.com, B38611@freescale.com,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49695 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754730Ab3DYH7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 03:59:39 -0400
In-Reply-To: <1366397444.2716.8.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 19 Apr 2013 19:50:44 +0100

> On Fri, 2013-04-19 at 19:10 +0100, Jim Baxter wrote:
>> Enables hardware generation of IP header and
>> protocol specific checksums for transmitted
>> packets.
>> 
>> Enabled hardware discarding of received packets with
>> invalid IP header or protocol specific checksums.
>> 
>> The feature is enabled by default but can be
>> enabled/disabled by ethtool.
>> 
>> Signed-off-by: Fugang Duan <B38611@freescale.com>
>> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
> 
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
