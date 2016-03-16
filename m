From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next 2/2] team: remove duplicate set of flag IFF_MULTICAST
Date: Wed, 16 Mar 2016 11:00:02 +0100
Message-ID: <20160316100002.GA2254@nanopsycho.orion>
References: <1458122356-25021-1-git-send-email-zhangshengju@cmss.chinamobile.com>
 <1458122356-25021-3-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, j.vosburgh@gmail.com, netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37968 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934679AbcCPKAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 06:00:10 -0400
Received: by mail-wm0-f48.google.com with SMTP id l68so64193233wml.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 03:00:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1458122356-25021-3-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 16, 2016 at 10:59:16AM CET, zhangshengju@cmss.chinamobile.com wrote:
>Remove unnecessary set of flag IFF_MULTICAST, since ether_setup
>already does this.
>
>Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
