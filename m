From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Fri, 21 Oct 2016 20:34:36 -0700
Message-ID: <CAM_iQpW6_ZaShM4Tghiybsy0fr89gG_BkMycLXZMdKwrsqOyAg@mail.gmail.com>
References: <CAM_iQpV0vfwsToR=maxhGM+fvQLX9zqcpp14A-C9JNzLfKJy9g@mail.gmail.com>
 <20161021193951.GS23701@madcap2.tricolour.ca> <CAHC9VhSm21f-HurdGi7+D0LmHNkkKRyAsT-OHJEyOZgoJVYUNg@mail.gmail.com>
 <20161021.163342.2187677530255875866.davem@davemloft.net> <CAHC9VhTm7Qc0FwEE35c5uyfWz-5DH1mKQtHGYrNVhPHm9ze34Q@mail.gmail.com>
 <CAHC9VhTzYQ3ZTnecZNQe7v5VTqSWsJeRCL+Qhwfk-nEuRQ-D5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Richard Guy Briggs <rgb@redhat.com>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Elad Raz <e@eladraz.com>
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:37044 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935797AbcJVDe6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 23:34:58 -0400
Received: by mail-it0-f46.google.com with SMTP id m138so27989627itm.0
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 20:34:57 -0700 (PDT)
In-Reply-To: <CAHC9VhTzYQ3ZTnecZNQe7v5VTqSWsJeRCL+Qhwfk-nEuRQ-D5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2016 at 6:55 PM, Paul Moore <paul@paul-moore.com> wrote:
> It's the end of my day, and commitments over the weekend will limit
> how much additional testing/work I can do so I went ahead and just
> posted a simple revert to netdev, it should be in your inbox already.
> Please fix this, either through a revert, or preferably some other fix
> we haven't thought of yet, in time for -rc2.

Creative artificial deadline! Next time pick -rc1 please so that no single
fix can go in after merge window!!
