From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7 01/10] qed: Add module with basic common
 support
Date: Sun, 25 Oct 2015 05:14:26 -0700 (PDT)
Message-ID: <20151025.051426.2109247189070163344.davem@davemloft.net>
References: <1445490417-8845-2-git-send-email-Yuval.Mintz@qlogic.com>
	<20151024.051149.1911984823506391327.davem@davemloft.net>
	<B5657A6538887040AD3A81F1008BEC63E53F6F@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbbJYL6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 07:58:06 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63E53F6F@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Sun, 25 Oct 2015 06:18:51 +0000

> I'd rather leave this as-is instead of making changes I'd have to revert
> later on, but if your 'code buds' reject this, I'll make the change.

Add facilities and flexibility when you need it rather than beforehand.
