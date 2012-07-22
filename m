From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] rtnl: do not include num_rx_queues into msg
 when CONFIG_RPS is not set
Date: Sun, 22 Jul 2012 12:27:46 -0700 (PDT)
Message-ID: <20120722.122746.1524911782331447848.davem@davemloft.net>
References: <1342942002-26731-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfr@canb.auug.org.au
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416Ab2GVT1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 15:27:47 -0400
In-Reply-To: <1342942002-26731-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun, 22 Jul 2012 09:26:42 +0200

> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Jiri, I've been patiently waiting for you to ACK Mark A. Greear's
patch fixing this bug, did you not see it at all?

http://patchwork.ozlabs.org/patch/172393/

I'm just going to apply it since you're not watching for fixes
for code you've changed.
