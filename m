From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: Re: [next-queue PATCH v8 0/6] TSN: Add qdisc based config interface for CBS
Date: Mon, 16 Oct 2017 15:20:05 -0700
Message-ID: <87zi8qloq2.fsf@intel.com>
References: <20171014002534.19896-1-vinicius.gomes@intel.com> <20171016.205146.1053238236578937188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com, henrik@austad.us, levipearson@gmail.com,
        rodney.cummings@ni.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:16810 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752519AbdJPWUH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 18:20:07 -0400
In-Reply-To: <20171016.205146.1053238236578937188.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

David Miller <davem@davemloft.net> writes:

> I'm fine with this patch set.  I see it's against Jeff's next-queue, so
> where exactly do you want this to be merged?  My net-next tree?

I think it going through Jeff's next-queue makes more sense.

Anyway, I will send a v9 later today fixing the padding issue that David
Laight pointed out.

>
> Thank you.

Cheers,
