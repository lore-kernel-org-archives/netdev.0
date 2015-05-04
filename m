From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/10] be2net: add support for spoofchk setting
Date: Mon, 04 May 2015 11:58:59 -0400 (EDT)
Message-ID: <20150504.115859.519940284663048316.davem@davemloft.net>
References: <1430722042-26449-1-git-send-email-sathya.perla@emulex.com>
	<1430722042-26449-2-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36386 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbbEDP7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 11:59:05 -0400
In-Reply-To: <1430722042-26449-2-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Mon,  4 May 2015 02:47:13 -0400

> From: Kalesh AP <kalesh.purayil@emulex.com>
> 
> This patch adds support for spoofchk configuration for VFs.
> When it is enabled, "spoof checking" is done for both MAC-address and VLAN.
> This feature is supported in Skyhawk FW version 10.6.31.0 and above.
> 
> Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

You're going to have to explain exactly what the spoof checking facility
of the card actually does.
