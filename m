From: David Miller <davem@davemloft.net>
Subject: Re: bnx2x: VF RSS support
Date: Thu, 05 Sep 2013 12:45:40 -0400 (EDT)
Message-ID: <20130905.124540.1074524380635734466.davem@davemloft.net>
References: <1378292962-5537-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148Ab3IEQpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 12:45:42 -0400
In-Reply-To: <1378292962-5537-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ariel Elior" <ariele@broadcom.com>
Date: Wed, 4 Sep 2013 14:09:20 +0300

> This patch series adds the capability for VF functions to use multiple queues
> and Receive / Transmit side scaling.
> 
> Patch #1 enhances the PF's side database to allow for multiple queues per PF
> and configure the HW appropriately, and the PF side of the VF PF channel
> message for configuring the RSS.
> 
> Patch #2 adds to the VF side the ability to request multiple queues, and if
> obtained to configure RSS for them over the VF PF channel.

Series applied, thanks.
