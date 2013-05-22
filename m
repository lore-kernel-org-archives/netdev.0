From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] qlcnic: Bug fixes
Date: Wed, 22 May 2013 14:52:51 -0700 (PDT)
Message-ID: <20130522.145251.1708408348135941334.davem@davemloft.net>
References: <1369164421-20996-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab3EVVww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 17:52:52 -0400
In-Reply-To: <1369164421-20996-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Tue, 21 May 2013 15:26:58 -0400

> This patch series includes following bug fixes:
> * Fix probe failure path by returning proper error codes.
> * Removed access to netdev->trans_start in driver.
> * Fix netdev->features manipulation as part of change in EPORT
>   features
> 
> Please apply to net.

Series applied, thanks.
