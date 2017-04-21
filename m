From: Ian Kumlien <ian.kumlien@gmail.com>
Subject: Re: [RFC] change the default Kconfig value of mlx5_en
Date: Fri, 21 Apr 2017 21:51:15 +0200
Message-ID: <CAA85sZtBo5dORg4sj8X_SROBU0ySh3_CQh1WiYcVX-RVv4E+gA@mail.gmail.com>
References: <CAA85sZumYPfUg_yA=5azrHneqq-XBmHiGNgRaEvBwbewVRj11w@mail.gmail.com>
 <20170421.154745.182611990085743539.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: saeedm@mellanox.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:35763 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425602AbdDUTvh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:51:37 -0400
Received: by mail-lf0-f46.google.com with SMTP id 75so49874056lfs.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:51:37 -0700 (PDT)
In-Reply-To: <20170421.154745.182611990085743539.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 9:47 PM, David Miller <davem@davemloft.net> wrote:
> From: Ian Kumlien <ian.kumlien@gmail.com>
> Date: Fri, 21 Apr 2017 21:45:00 +0200
>
>> The mellanox driver supports both ethernet and infiniband, but it
>> is located in the ethernet drivers - the ethernet support should
>> default to 'yes'.
>
> I don't have that card and I therefore perhaps don't want that driver
> in my builds.

Ah, sorry - really tired here, got it in to my head that this was just
a flag for
the driver to build the ethernet module, sorry

> This is not an appropriate change, sorry.

Nope, completely agree... sorry for the noise
