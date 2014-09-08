From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: do not ignore autoneg in
 mlx4_en_set_pauseparam()
Date: Mon, 08 Sep 2014 15:57:19 -0700 (PDT)
Message-ID: <20140908.155719.1988736925774667859.davem@davemloft.net>
References: <1410194813-994-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755102AbaIHW5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 18:57:20 -0400
In-Reply-To: <1410194813-994-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Mon,  8 Sep 2014 18:46:53 +0200

> The driver does not support pause autonegotiation so it should return
> -EINVAL when the function is called with non-zero autoneg.
> 
> Cc: Amir Vadai <amirv@mellanox.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks Ivan.
