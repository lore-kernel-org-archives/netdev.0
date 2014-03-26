From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] bnx2x: SR-IOV patch series
Date: Tue, 25 Mar 2014 21:14:19 -0400 (EDT)
Message-ID: <20140325.211419.1337120944299675542.davem@davemloft.net>
References: <1395591147-26350-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775AbaCZBOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 21:14:20 -0400
In-Reply-To: <1395591147-26350-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Sun, 23 Mar 2014 18:12:22 +0200

> (With the exception of the first patch) This series contains IOV-related
> patches, where the main changes are related to the driver's IOV-support
> backbone - it adds a new workqueue for IOV related tasks and removes the vfop
> mechanism from the driver.
> 
> Please consider applying this series to `net-next'.

Series applied, thanks.
