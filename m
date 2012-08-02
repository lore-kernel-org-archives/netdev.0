From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH iproute2] ss: report SK_MEMINFO_BACKLOG
Date: Thu, 02 Aug 2012 14:24:30 +0800
Message-ID: <501A1D1E.6020404@gmail.com>
References: <1343294420.2626.11264.camel@edumazet-glaptop>  <CAGK4HS-fUp2ZiW9F_ZogOXQo5_2ptcBHT9Y2j25ZaoXrYKnbAQ@mail.gmail.com>  <20120727100806.360764f5@nehalam.linuxnetplumber.net> <1343409083.2626.13105.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:41449 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209Ab2HBGZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 02:25:14 -0400
Received: by obbuo13 with SMTP id uo13so13379769obb.19
        for <netdev@vger.kernel.org>; Wed, 01 Aug 2012 23:25:13 -0700 (PDT)
In-Reply-To: <1343409083.2626.13105.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet said, at 2012/7/28 1:11:
> 
> By the way, it seems "ss -u" still uses /proc/net/udp , and not
> inet_diag ?

Yes, UDP doesn't use inet_diag.
Can you provide a patch, we are willing to see it?

> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
