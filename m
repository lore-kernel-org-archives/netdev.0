From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [ovs-dev] [PATCH net-next] openvswitch: Use ether_addr_copy
Date: Wed, 19 Feb 2014 11:32:41 -0800
Message-ID: <CALnjE+rvh7Rqpw1expkhJtRGt7Quy8MVWkUVfjVh4BsPaj2jVg@mail.gmail.com>
References: <fee7d53a1cfdec0aec7ea35a1f2f4b5e66766ee3.1392750899.git.joe@perches.com>
	<20140218.181507.1046967430290052114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: joe@perches.com, "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog039.obsmtp.com ([74.125.150.113]:59346 "HELO
	na6sys009bog039.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754875AbaBSTcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 14:32:42 -0500
Received: by mail-ve0-f179.google.com with SMTP id jx11so882974veb.10
        for <netdev@vger.kernel.org>; Wed, 19 Feb 2014 11:32:42 -0800 (PST)
In-Reply-To: <20140218.181507.1046967430290052114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse is on vacation. So I applied it to ovs master.

Thanks.

On Tue, Feb 18, 2014 at 3:15 PM, David Miller <davem@davemloft.net> wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 18 Feb 2014 11:15:45 -0800
>
>> It's slightly smaller/faster for some architectures.
>>
>> Signed-off-by: Joe Perches <joe@perches.com>
>
> I'll let Jesse take this via his tree, thanks Joe.
> _______________________________________________
> dev mailing list
> dev@openvswitch.org
> http://openvswitch.org/mailman/listinfo/dev
