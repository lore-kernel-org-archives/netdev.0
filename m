From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fix NULL pointer dereference in br_handle_frame
Date: Thu, 12 Sep 2013 09:19:52 -0700
Message-ID: <1379002792.24408.21.camel@edumazet-glaptop>
References: <1378988195-2710-1-git-send-email-zhiguohong@tencent.com>
	 <1379001428-2727-1-git-send-email-zhiguohong@tencent.com>
	 <CAA7+ByXUnTi1+-yreK+q03Cbqg+FM7DTfQ9qXbyRbZ0N508JBQ@mail.gmail.com>
	 <1379002315.24408.19.camel@edumazet-glaptop>
	 <CAA7+ByUy5jL2hpkN+GBDRCXh_GM7qnS58iZvgp1RxZmoAqj+bQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Hong Zhiguo <zhiguohong@tencent.com>
To: Hong zhi guo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:52330 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754218Ab3ILQT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 12:19:59 -0400
Received: by mail-pd0-f176.google.com with SMTP id q10so16125pdj.35
        for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 09:19:59 -0700 (PDT)
In-Reply-To: <CAA7+ByUy5jL2hpkN+GBDRCXh_GM7qnS58iZvgp1RxZmoAqj+bQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-13 at 00:18 +0800, Hong zhi guo wrote:
> sorry, Eric, maybe I'm using wrong words. Thanks for your review and help.
> So you both prefer not testing IFF_BRIDGE_PORT. Let's take the new fix.

Please do not top post on netdev.

Thanks
