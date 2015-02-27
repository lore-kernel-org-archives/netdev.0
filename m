From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] rocker: add a check for NULL in
 rocker_probe_ports()
Date: Fri, 27 Feb 2015 15:59:18 -0500 (EST)
Message-ID: <20150227.155918.1581047845198975426.davem@davemloft.net>
References: <20150225133532.GU19745@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, sfeldma@gmail.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755438AbbB0U7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 15:59:21 -0500
In-Reply-To: <20150225133532.GU19745@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 25 Feb 2015 16:35:32 +0300

> Make sure kmalloc() succeeds.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
