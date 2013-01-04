From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resent] net/ipv4/ipconfig: really display the
 BOOTP/DHCP server's address.
Date: Fri, 04 Jan 2013 15:14:28 -0800 (PST)
Message-ID: <20130104.151428.641448458284804684.davem@davemloft.net>
References: <1357236132-12574-1-git-send-email-phdm@macqel.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: phdm@macqel.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754749Ab3ADXO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 18:14:29 -0500
In-Reply-To: <1357236132-12574-1-git-send-email-phdm@macqel.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe De Muyter <phdm@macqel.be>
Date: Thu,  3 Jan 2013 19:02:12 +0100

> Up to now, the debug and info messages from the ipconfig subsytem
> claim to display the IP address of the DHCP/BOOTP server but
> display instead the IP address of the bootserver.  Fix that.
> 
> Signed-off-by: Philippe De Muyter <phdm@macqel.be>

Applied.
