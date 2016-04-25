From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] devlink: export header
Date: Mon, 25 Apr 2016 16:49:28 -0400 (EDT)
Message-ID: <20160425.164928.589496341257465225.davem@davemloft.net>
References: <20160422095517.545fe658@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964874AbcDYUtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 16:49:33 -0400
In-Reply-To: <20160422095517.545fe658@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 22 Apr 2016 09:55:17 -0700

> Export devlink.h when doing make headers install.
> I am going to investigate just doing all headers in the directory,
> but lets add missing piece for now.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

This is already exported in the 'net' tree.
