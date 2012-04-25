From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/14 v2] usb/net: rndis: break out <linux/rndis.h>
 defines
Date: Wed, 25 Apr 2012 19:45:45 -0400 (EDT)
Message-ID: <20120425.194545.1399301965144213487.davem@davemloft.net>
References: <1335367808-4254-1-git-send-email-linus.walleij@linaro.org>
	<A1F3067C9B68744AA19F6802BAB8FFDC0DD36CAE@TK5EX14MBXC221.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linus.walleij@linaro.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, gregkh@linuxfoundation.org,
	balbi@ti.com, jussi.kivilinna@mbnet.fi,
	yongjun_wei@trendmicro.com.cn, ben@decadent.org.uk
To: haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54981 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932464Ab2DYXqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 19:46:00 -0400
In-Reply-To: <A1F3067C9B68744AA19F6802BAB8FFDC0DD36CAE@TK5EX14MBXC221.redmond.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Wed, 25 Apr 2012 20:38:31 +0000

> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>

I don't think you really thoroughly reviewed this patch, otherwise
you would have noticed the duplicate definitions that result from
this patch which adds hundreds of warnings to the build.
