From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] be2net: Show newly flashed FW ver in
 ethtool
Date: Tue, 27 Sep 2011 13:30:41 -0400 (EDT)
Message-ID: <20110927.133041.1427360174231452828.davem@davemloft.net>
References: <1317122035-5533-1-git-send-email-sathya.perla@emulex.com>
	<747547b9-60c7-41b7-9584-23d0374b4503@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Suresh.Reddy@emulex.com
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854Ab1I0Raq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 13:30:46 -0400
In-Reply-To: <747547b9-60c7-41b7-9584-23d0374b4503@exht2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Tue, 27 Sep 2011 16:43:55 +0530

> This fix provides a newly flashed FW version (appended, in braces) along with
> the currently running FW version via ethtool. The newly flashed version runs only after a system reset.
> 
> Signed-off-by: Suresh Reddy <Suresh.Reddy@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
