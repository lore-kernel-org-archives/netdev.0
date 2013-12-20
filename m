From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net_sched: fix a regression in tcf_proto_lookup_ops()
Date: Fri, 20 Dec 2013 15:22:12 -0500
Message-ID: <52B4A6F4.6050702@mojatatu.com>
References: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>	 <52B434FA.8080309@mojatatu.com>	 <1387550222.19078.434.camel@edumazet-glaptop2.roam.corp.google.com>	 <52B45851.90208@mojatatu.com>	 <1387555659.19078.439.camel@edumazet-glaptop2.roam.corp.google.com>	 <1387560028.19078.442.camel@edumazet-glaptop2.roam.corp.google.com>	 <1387560578.19078.443.camel@edumazet-glaptop2.roam.corp.google.com>	 <1387562658.19078.448.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAM_iQpUQ3iaq+X+CngqJCGWq5Ep_XhcfWEKqrCQcZ3iC6Uz_qA@mail.gmail.com>	 <1387568188.19078.453.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAM_iQpV+WJdeOHOyGENT2XWn=ytjBirBo1G4H2b_QziKHWFw0g@mail.gmail.com> <1387570492.19078.463.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:35984 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882Ab3LTUWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 15:22:13 -0500
Received: by mail-ie0-f175.google.com with SMTP id x13so3695520ief.34
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 12:22:13 -0800 (PST)
In-Reply-To: <1387570492.19078.463.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/13 15:14, Eric Dumazet wrote:

> This will be a separate patch, as the faulty commit is different.
> ( 1f747c26c48bb290c79c34e155860c7e2ec3926a net_sched: convert
> tc_action_ops to use struct list_head)
>

Ok, I hope Dave pulls those changes in - plan to pay closer attention
over the weekend.

cheers,
jamal

>
>
