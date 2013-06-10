From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] igmp: hash a hash table to speedup ip_check_mc_rcu()
Date: Mon, 10 Jun 2013 09:58:12 +0800
Message-ID: <CAM_iQpXkQWn1Hs1xML_08PKNdfz9KkLOTLiNr5Nbq9HS9gYQ2g@mail.gmail.com>
References: <20130605175724.GA2576@sbohrermbp13-local.rgmadvisors.com>
	<1370455997.24311.290.camel@edumazet-glaptop>
	<20130605203253.GB2576@sbohrermbp13-local.rgmadvisors.com>
	<1370465535.24311.304.camel@edumazet-glaptop>
	<1370565301.24311.396.camel@edumazet-glaptop>
	<20130607144833.GB2995@sbohrermbp13-local.rgmadvisors.com>
	<1370620137.24311.433.camel@edumazet-glaptop>
	<kouci0$2eu$1@ger.gmane.org>
	<1370668993.24311.460.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:56047 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431Ab3FJB6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jun 2013 21:58:13 -0400
Received: by mail-oa0-f46.google.com with SMTP id h2so5282141oag.5
        for <netdev@vger.kernel.org>; Sun, 09 Jun 2013 18:58:13 -0700 (PDT)
In-Reply-To: <1370668993.24311.460.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for explanation!

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>
