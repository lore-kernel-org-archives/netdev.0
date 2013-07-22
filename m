From: <Narendra_K@Dell.com>
Subject: Re: [patch net-next v3 1/3] net: add ndo to get id of physical port
 of the device
Date: Mon, 22 Jul 2013 19:14:47 +0530
Message-ID: <20130722134427.GA6741@fedora18-dev.oslab.blr.amer.dell.com>
References: <1374498317-6442-1-git-send-email-jiri@resnulli.us>
 <1374498317-6442-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<stephen@networkplumber.org>, <bhutchings@solarflare.com>,
	<john.r.fastabend@intel.com>, <or.gerlitz@gmail.com>
To: <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:65318 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754098Ab3GVNpb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 09:45:31 -0400
In-Reply-To: <1374498317-6442-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 22, 2013 at 06:35:15PM +0530, Jiri Pirko wrote:
> 
> This patch adds a ndo for getting physical port of the device. Driver
> which is aware of being virtual function of some physical port should
> implement this ndo. This is applicable not only for IOV, but for other
> solutions (NPAR, multichannel) as well. Basically if there is possible
> to have multiple netdevs on the single hw port.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>
> ---

Signed-off-by: Narendra K <narendra_k@dell.com>

-- 
With regards,
Narendra K
Linux Engineering
Dell Inc.
