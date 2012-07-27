From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ss: report SK_MEMINFO_BACKLOG
Date: Fri, 27 Jul 2012 19:11:23 +0200
Message-ID: <1343409083.2626.13105.camel@edumazet-glaptop>
References: <1343294420.2626.11264.camel@edumazet-glaptop>
	 <CAGK4HS-fUp2ZiW9F_ZogOXQo5_2ptcBHT9Y2j25ZaoXrYKnbAQ@mail.gmail.com>
	 <20120727100806.360764f5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59256 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709Ab2G0RLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 13:11:31 -0400
Received: by bkwj10 with SMTP id j10so2029259bkw.19
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 10:11:29 -0700 (PDT)
In-Reply-To: <20120727100806.360764f5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-27 at 10:08 -0700, Stephen Hemminger wrote:
> I am holding this until after 3.5 iproute2 is released.
> 
> Still want to get a couple more features in 3.5 iproute2, the work Pavel is
> doing on save/restore cleanup, and the bridge fdb stuff.
> 

By the way, it seems "ss -u" still uses /proc/net/udp , and not
inet_diag ?
