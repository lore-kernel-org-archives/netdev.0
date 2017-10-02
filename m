From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: Re: [next-queue PATCH v2 3/5] net/sched: Introduce the user API for the CBS shaper
Date: Mon, 02 Oct 2017 10:07:07 -0700
Message-ID: <87efqlfphg.fsf@intel.com>
References: <20170930002657.15291-1-vinicius.gomes@intel.com> <20170930002657.15291-4-vinicius.gomes@intel.com> <CAM_iQpWGHE7hgwEZDO+oRGgWdrdYYofnHfuQq3fMOO-yFj7NSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>, andre.guedes@intel.com,
        Ivan Briano <ivan.briano@intel.com>,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        Henrik Austad <henrik@austad.us>, levipearson@gmail.com,
        rodney.cummings@ni.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:11258 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751061AbdJBRHN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 13:07:13 -0400
In-Reply-To: <CAM_iQpWGHE7hgwEZDO+oRGgWdrdYYofnHfuQq3fMOO-yFj7NSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Cong Wang <xiyou.wangcong@gmail.com> writes:

> On Fri, Sep 29, 2017 at 5:26 PM, Vinicius Costa Gomes
> <vinicius.gomes@intel.com> wrote:
>> Export the API necessary for configuring the CBS shaper (implemented
>> in the next patch) via the tc tool.
>
> This one can be folded into patch 4/5.

Will do.


Cheers,
