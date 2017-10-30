From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: More painful merges...
Date: Mon, 30 Oct 2017 17:41:31 +0100
Message-ID: <20171030164131.GD4115@nanopsycho.orion>
References: <20171030.211551.790664985307439262.davem@davemloft.net>
 <CAM_iQpUTauPL7Z_s-0kbp+nbg17fniMBhOyQ4tDVVmC=qFFy=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:46151 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932369AbdJ3Qle (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 12:41:34 -0400
Received: by mail-wm0-f43.google.com with SMTP id m72so17173702wmc.1
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 09:41:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpUTauPL7Z_s-0kbp+nbg17fniMBhOyQ4tDVVmC=qFFy=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 30, 2017 at 04:58:25PM CET, xiyou.wangcong@gmail.com wrote:
>On Mon, Oct 30, 2017 at 5:15 AM, David Miller <davem@davemloft.net> wrote:
>>
>> BPF and tc action bug fixes in 'net' caused some extremely
>> painful merges with 'net-next'.
>>
>> Could the interested parties please take a look at 'net-next'
>> and send me any necessary fixes, as I did the best that I
>> could.
>>
>
>The tcf_block_put_ext() part looks good to me. I will run
>some tests to make sure.

Looks fine to me as well.
