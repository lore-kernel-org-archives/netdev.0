From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: allow live mac address change
Date: Thu, 03 Jan 2013 01:58:45 -0800 (PST)
Message-ID: <20130103.015845.17138214634424115.davem@davemloft.net>
References: <20121231140021.5ec82f3a@nehalam.linuxnetplumber.net>
	<20130101081949.GA1531@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046Ab3ACJ6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 04:58:46 -0500
In-Reply-To: <20130101081949.GA1531@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 1 Jan 2013 09:19:49 +0100

> Mon, Dec 31, 2012 at 11:00:21PM CET, shemminger@vyatta.com wrote:
>>The VXLAN pseudo-device doesn't care if the mac address changes
>>when device is up.
>>
>>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
 ...
> Reviewed-by: Jiri Pirko <jiri@resnulli.us>

Applied.
