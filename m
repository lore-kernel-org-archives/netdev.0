From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch] net: remove an unneeded check
Date: Mon, 29 Jul 2013 23:17:54 +0200
Message-ID: <20130729211754.GA6386@minipsycho.orion>
References: <20130729191519.GA11874@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:57436 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755129Ab3G2VR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 17:17:59 -0400
Received: by mail-ea0-f181.google.com with SMTP id d10so2037757eaj.26
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 14:17:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130729191519.GA11874@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 29, 2013 at 09:15:19PM CEST, dan.carpenter@oracle.com wrote:
>"ifa->ifa_label" is an array inside the in_ifaddr struct.  It can never
>be NULL so we can remove this check.
>
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Reviewed-by: Jiri Pirko <jiri@resnulli.us>
