From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hso: fix module unloading
Date: Tue, 25 Apr 2017 11:52:39 -0400 (EDT)
Message-ID: <20170425.115239.2245457744587314438.davem@davemloft.net>
References: <1493061519-15785-1-git-send-email-andreas@kemnade.info>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, peter@hurleysoftware.com,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, letux-kernel@openphoenux.org
To: andreas@kemnade.info
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41064 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951060AbdDYPwo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:52:44 -0400
In-Reply-To: <1493061519-15785-1-git-send-email-andreas@kemnade.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Kemnade <andreas@kemnade.info>
Date: Mon, 24 Apr 2017 21:18:39 +0200

> keep tty driver until usb driver is unregistered
> rmmod hso
> produces traces like this without that:
 ...
> Signed-off-by: Andreas Kemnade <andreas@kemnade.info>

Applied, thank you.
