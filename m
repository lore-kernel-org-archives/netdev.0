From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] switchdev: documentation updates
Date: Wed, 03 Jun 2015 23:47:40 -0700 (PDT)
Message-ID: <20150603.234740.1468282737249755637.davem@davemloft.net>
References: <1433389423-58467-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, gospo@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44393 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbbFDGrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 02:47:41 -0400
In-Reply-To: <1433389423-58467-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed,  3 Jun 2015 20:43:39 -0700

> Update the switchdev documentation to clarify that for IPV4 FIB object, the add
> op is used for both adding and modifying the FIB entry on the device.
> 
> I found a few other white-space and grammer issues to fix, and to clarify the
> static FDB ops.

Series applied, thanks Scott.
