From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 2/3 net-next] team: cleanup netpoll clode
Date: Wed, 24 Jul 2013 21:08:03 +0200
Message-ID: <20130724190803.GC1632@minipsycho.orion>
References: <20130724115141.63bba894@nehalam.linuxnetplumber.net>
 <20130724115244.3fd7a43d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:43017 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab3GXTIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 15:08:07 -0400
Received: by mail-ea0-f178.google.com with SMTP id l15so435177eak.37
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 12:08:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130724115244.3fd7a43d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jul 24, 2013 at 08:52:44PM CEST, stephen@networkplumber.org wrote:
>This started out with fixing a sparse warning, then I realized that
>the wrapper function team_netpoll_info could just be collapsed away
>by rolling it into the enable code.
>
>Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Acked-by: Jiri Pirko <jiri@resnulli.us>
