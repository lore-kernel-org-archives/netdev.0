From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net-next 1/1] net: vlan: Use sizeof instead of literal number
Date: Tue, 18 Oct 2016 09:49:37 +0800
Message-ID: <CA+6hz4pQQg8U4+Fs47zEUxe1Khb+oqqQSKGVyT9fmzjhObUmvA@mail.gmail.com>
References: <1476752270-12590-1-git-send-email-fgao@ikuai8.com> <20161017.213658.349412154638384827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Patrick McHardy <kaber@trash.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgau1.qq.com ([54.206.16.166]:50700 "EHLO smtpbgau1.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933265AbcJRBuB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 21:50:01 -0400
Received: from mail-vk0-f53.google.com (unknown [209.85.213.53])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 09:49:38 +0800 (CST)
Received: by mail-vk0-f53.google.com with SMTP id b186so199889566vkb.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 18:49:39 -0700 (PDT)
In-Reply-To: <20161017.213658.349412154638384827.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, Oct 18, 2016 at 9:36 AM, David Miller <davem@davemloft.net> wrote:
>
> It never makes sense to send the same patch for both net and net-next.
>
> If it's a bug fix, it goes to 'net'.  And it will be eventually
> be naturally merged into 'net-next'.
>
> Otherwise, if it's a new feature, cleanup, or optimization it goes to
> 'net-next'.

Because I forget add the "net-next" in the title of first patch, so I
send the second patch with right title.
And I have replied the first patch and said the reason.

Regards
Feng
