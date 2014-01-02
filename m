From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] bnx2: Add better support for auto-mdix
Date: Wed, 01 Jan 2014 22:05:15 -0500 (EST)
Message-ID: <20140101.220515.1211296379156437288.davem@davemloft.net>
References: <1388560955-32586-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbaABDFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 22:05:20 -0500
In-Reply-To: <1388560955-32586-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>
Date: Tue, 31 Dec 2013 23:22:31 -0800

> Michael Chan (4):
>   bnx2: Advertise nothing when speed is forced
>   bnx2: Enable auto-mdix when autoneg is disabled.
>   bnx2: Report MDI/MDIX status to ethtool.
>   bnx2: Update version to 2.2.5.

Series applied, please consider the enhancement for advertising this
feature via ethtool that Ben mentioned.
