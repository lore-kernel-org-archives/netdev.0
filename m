From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 2/2] switchdev: fix: pass correct obj size
 when deferring obj add
Date: Fri, 30 Oct 2015 20:24:08 +0900 (KST)
Message-ID: <20151030.202408.445013141014703893.davem@davemloft.net>
References: <1446099451-62999-1-git-send-email-sfeldma@gmail.com>
	<1446099451-62999-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030730AbbJ3LYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 07:24:10 -0400
In-Reply-To: <1446099451-62999-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed, 28 Oct 2015 23:17:31 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> Fixes: 4d429c5dd ("switchdev: introduce possibility to defer obj_add/del")
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Applied.
