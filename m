From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] igb: fix a typo in igb_reset_q_vector()
Date: Tue, 21 Apr 2015 21:35:04 -0700
Message-ID: <CAM_iQpWjUiJdb5E8QHvquzweQsEEdDQqtxJLyBL8KM1zOL6W9Q@mail.gmail.com>
References: <1429658433-8634-1-git-send-email-xiyou.wangcong@gmail.com>
	<5536EAA3.10701@lab.ntt.co.jp>
	<1429662577.2638.201.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:36518 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168AbbDVEfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 00:35:05 -0400
Received: by pdea3 with SMTP id a3so262702118pde.3
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 21:35:04 -0700 (PDT)
In-Reply-To: <1429662577.2638.201.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2015 at 5:29 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> On Wed, 2015-04-22 at 09:26 +0900, Toshiaki Makita wrote:
>> Hi Cong Wang,
>>
>> I have already sent a patch to intel's tree.
>> http://git.kernel.org/cgit/linux/kernel/git/jkirsher/net-queue.git/commit/?h=dev-queue&id=02ac4b65689f8df824117395fd8d160c04161a7b
>>

I didn't know this tree, I use -net tree.

>>
>
> Oops, yeah.  I already have this in my queue.  I wondered why the patch
> seemed familiar, Cong dropping your patch since I already have
> Tochiaki's patch in my queue.

Sure. Please queue it for -stable too, since it apparently fixes a bug.

Thanks!
