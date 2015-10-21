From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] vsock: fix missing cleanup when misc_register failed
Date: Wed, 21 Oct 2015 07:41:24 -0700 (PDT)
Message-ID: <20151021.074124.2282603774222125606.davem@davemloft.net>
References: <1445182556-24073-1-git-send-email-omarapazanadi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: omarapazanadi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44442 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbbJUOZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 10:25:00 -0400
In-Reply-To: <1445182556-24073-1-git-send-email-omarapazanadi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <omarapazanadi@gmail.com>
Date: Sun, 18 Oct 2015 23:35:56 +0800

> reset transport and unlock if misc_register failed.
> 
> Signed-off-by: Gao feng <omarapazanadi@gmail.com>

Applied.
