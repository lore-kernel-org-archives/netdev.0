From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] usbnet: handle PM failure gracefully
Date: Wed, 19 Dec 2012 12:47:29 -0800 (PST)
Message-ID: <20121219.124729.538705719396423872.davem@davemloft.net>
References: <1355841929-983-1-git-send-email-oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oneukum@suse.de
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396Ab2LSUra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 15:47:30 -0500
In-Reply-To: <1355841929-983-1-git-send-email-oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Tue, 18 Dec 2012 15:45:29 +0100

> If a device fails to do remote wakeup, this is no reason
> to abort an open totally. This patch just continues without
> runtime PM.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

Applied.
