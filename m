From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: use scnprintf() instead of sprintf()
Date: Mon, 17 Dec 2012 20:52:19 -0800 (PST)
Message-ID: <20121217.205219.1220317802601025934.davem@davemloft.net>
References: <20121217110001.3eaf3ac5@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gang.chen@asianux.com
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55062 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862Ab2LREwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 23:52:20 -0500
In-Reply-To: <20121217110001.3eaf3ac5@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Date: Mon, 17 Dec 2012 11:00:01 -0500

> 
> As reported by Chen Gang <gang.chen@asianux.com>, we should ensure there
> is enough space when formatting the sysfs buffers.
> 
> Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

Applied.
