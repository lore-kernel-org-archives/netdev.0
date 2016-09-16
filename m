From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 07/14] tcp: export data delivery rate
Date: Fri, 16 Sep 2016 13:11:54 -0700
Message-ID: <CANn89iK4wuF9boN6D2fq_3Ca2RWh8V9ohbYnKPf5s_LQsKWzdw@mail.gmail.com>
References: <1474051743-13311-8-git-send-email-ncardwell@google.com>
 <201609171104.7NaqQo41%fengguang.wu@intel.com> <CADVnQymVmhX86St6aeTh7asW68cC8d3qOZEBrV-ajp1okbx6Zw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Van Jacobson <vanj@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:35454 "EHLO
        mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965403AbcIPUMA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 16:12:00 -0400
Received: by mail-yw0-f180.google.com with SMTP id u82so90599763ywc.2
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 13:12:00 -0700 (PDT)
In-Reply-To: <CADVnQymVmhX86St6aeTh7asW68cC8d3qOZEBrV-ajp1okbx6Zw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 1:03 PM, Neal Cardwell <ncardwell@google.com> wrote:

>
> Looks like 'rate' should be 'rate64'. I will include this fix in the
> next version of the patch series.
>
> neal


Oh, right you are !
