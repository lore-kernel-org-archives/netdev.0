From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Offloading bonds to hardware
Date: Mon, 16 Nov 2015 01:51:13 -0500 (EST)
Message-ID: <20151116.015113.693840357905455307.davem@davemloft.net>
References: <56462E38.5090600@gmail.com>
	<20151113.141006.1048458234203733687.davem@davemloft.net>
	<77EF4405DD4BB54AACCE7DB593DF6A9AA08010@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, sfeldma@gmail.com,
	jiri@resnulli.us, nikolay@cumulusnetworks.com, idosch@mellanox.com,
	gospo@cumulusnetworks.com
To: pjonnala@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbbKPGvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 01:51:18 -0500
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9AA08010@SJEXCHMB14.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Premkumar Jonnala <pjonnala@broadcom.com>
Date: Mon, 16 Nov 2015 06:12:24 +0000

> Thank you for the feedback David.  I am currently handling/implementing
> these notifications in a custom (closed source) driver.  I will update the diff 
> with an actual demo of the handler, and resend the diffs.

No, I don't want a damn "demo", I want a real use in an upstream
driver.

You cannot add infrastructure that only has a real use in your
out-of-tree or closed source driver.

That is _completely_ and _totally_ unacceptable.
