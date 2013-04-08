From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: be less verbose about non-critical
 firmware errors
Date: Mon, 08 Apr 2013 12:00:54 -0400 (EDT)
Message-ID: <20130408.120054.197653878098222928.davem@davemloft.net>
References: <1365094628-21520-1-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, neepatel@cisco.com
To: sassmann@kpanic.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936559Ab3DHQA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 12:00:56 -0400
In-Reply-To: <1365094628-21520-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@kpanic.de>
Date: Thu,  4 Apr 2013 18:57:08 +0200

> If a feature is not supported by firmware no need to print an error message.
> This surpresses the following harmless message on boot up and ethtool query.
> enic: Error 1 devcmd 36
> 
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>

Applied.
