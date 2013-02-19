From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] bonding: set sysfs device_type to 'bond'
Date: Tue, 19 Feb 2013 00:53:16 -0500 (EST)
Message-ID: <20130219.005316.1589210324070927066.davem@davemloft.net>
References: <20130218.144934.1015644582010518018.davem@davemloft.net>
	<1361235563-2684-1-git-send-email-cardoe@cardoe.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: cardoe@cardoe.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54267 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754598Ab3BSFxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 00:53:18 -0500
In-Reply-To: <1361235563-2684-1-git-send-email-cardoe@cardoe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Doug Goldstein <cardoe@cardoe.com>
Date: Mon, 18 Feb 2013 18:59:23 -0600

> Sets the sysfs device_type to 'bond' for udev. This allows udev rules to
> be created for bond devices. This is similar to how other network
> devices set their device_type.
> 
> Signed-off-by: Doug Goldstein <cardoe@cardoe.com>

Applied.
