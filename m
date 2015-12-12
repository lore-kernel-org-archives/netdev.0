From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: core: Fix temperature sensor index
 during initialization
Date: Sat, 12 Dec 2015 00:46:12 -0500 (EST)
Message-ID: <20151212.004612.52689578296384782.davem@davemloft.net>
References: <1449854760-15190-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093AbbLLFqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 00:46:14 -0500
In-Reply-To: <1449854760-15190-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 11 Dec 2015 18:26:00 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Sensor index should be passed instead of 0. For now, this does not make
> a difference, since there is so far only one temperature sensor
> exposed by HW.
> 
> Fixes: 89309da39 ("mlxsw: core: Implement temperature hwmon interface")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
