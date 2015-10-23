From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 3/3] switchdev: split switchdev_attr into
 individual structs
Date: Fri, 23 Oct 2015 06:32:44 -0700 (PDT)
Message-ID: <20151023.063244.1017914313842957944.davem@davemloft.net>
References: <1445570717-40780-1-git-send-email-sfeldma@gmail.com>
	<1445570717-40780-3-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbbJWNQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 09:16:15 -0400
In-Reply-To: <1445570717-40780-3-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Thu, 22 Oct 2015 20:25:17 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> This was already done for switchdev_objs.   Changing switchdev_attrs to new
> style makes switchdev API consistent for both attrs and objs.
> 
> No functional changes here.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Applied.
