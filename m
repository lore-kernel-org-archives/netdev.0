From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 3/3] dsa: Move switch drivers to new directory
 drivers/net/dsa
Date: Sun, 27 Nov 2011 19:16:12 -0800
Message-ID: <1322450172.32357.2.camel@Joe-Laptop>
References: <1322449506.7454.34.camel@deadeye>
	 <1322449713.7454.36.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:44959 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755930Ab1K1DQN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Nov 2011 22:16:13 -0500
In-Reply-To: <1322449713.7454.36.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-28 at 03:08 +0000, Ben Hutchings wrote:
> Support for specific hardware belongs under drivers/net/ not net/.

Not sure I agree but maybe
drivers/net/ethernet/marvell/dsa?
