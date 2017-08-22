From: Bhumika Goyal <bhumirks@gmail.com>
Subject: Re: [PATCH] ptp: make ptp_clock_info const
Date: Tue, 22 Aug 2017 12:06:23 +0530
Message-ID: <CAOH+1jGDjGusOCYv+S4P9LGq9vbnYtMF1-NfnyjfGYiM2ugGpg@mail.gmail.com>
References: <1503336672-22918-1-git-send-email-bhumirks@gmail.com> <20170822062730.u2zj7qumzjcl4f6o@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Julia Lawall <julia.lawall@lip6.fr>, netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170822062730.u2zj7qumzjcl4f6o@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2017 at 11:57 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Mon, Aug 21, 2017 at 11:01:12PM +0530, Bhumika Goyal wrote:
>> File ptp_ixp46x.c is not tested as I could not find any architecture
>> to cross compile it.
>
> No problem.  Thanks for test compiling the other drivers.
>

By testing I meant that they have been checked by the compiler. I
haven't run the code on a hardware or some test data.

Thanks,
Bhumika

> Acked-by: Richard Cochran <richardcochran@gmail.com>
