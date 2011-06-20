From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]rionet: fix NULL pointer dereference in rionet_remove
Date: Sun, 19 Jun 2011 22:44:35 -0700 (PDT)
Message-ID: <20110619.224435.463338473109088359.davem@davemloft.net>
References: <1308410839.9175.11.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mporter@kernel.crashing.org,
	jj@chaosbits.net, cmdkhh@gmail.com
To: synmyth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075Ab1FTFot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 01:44:49 -0400
In-Reply-To: <1308410839.9175.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yinglin Luan <synmyth@gmail.com>
Date: Sat, 18 Jun 2011 23:27:15 +0800

> -static int rionet_setup_netdev(struct rio_mport *mport)
> +static int rionet_setup_netdev(struct rio_mport *mport, struct
> net_device *ndev)

This patch has been mangled by your email client.

Read Documentation/email-clients.txt

Send a test patch to yourself, make sure it applies for you.

Then resend your patch here.
