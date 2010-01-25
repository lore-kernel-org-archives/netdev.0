From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1 V4] net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC
 driver
Date: Mon, 25 Jan 2010 08:39:30 -0800
Message-ID: <20100125083930.0b52182b@nehalam>
References: <1264417272-3800-1-git-send-email-kristoffer@gaisler.com>
	<1264417272-3800-2-git-send-email-kristoffer@gaisler.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: Kristoffer Glembo <kristoffer@gaisler.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34297 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771Ab0AYQjl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 11:39:41 -0500
In-Reply-To: <1264417272-3800-2-git-send-email-kristoffer@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Jan 2010 12:01:12 +0100
Kristoffer Glembo <kristoffer@gaisler.com> wrote:

> Adds device driver for Aeroflex Gaisler 10/100 and 10/100/1G Ethernet MAC IP cores.
> 
> Signed-off-by: Kristoffer Glembo <kristoffer@gaisler.com>

Please consider adding ethtool support for things like settings (speed, duplex);
info, get_link, and checksum offload control

-- 
