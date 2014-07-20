From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net] net_sched: avoid generating same handle for u32 filters
Date: Sun, 20 Jul 2014 12:20:29 -0400
Message-ID: <53CBEC4D.5000103@mojatatu.com>
References: <1405643693-4880-1-git-send-email-xiyou.wangcong@gmail.com>	<53CAEC2F.4050808@mojatatu.com> <CAM_iQpU8P=sgbtOfjZ8QD6maoMCfwoiTgEsiEVG7M=j3M3v22g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34016 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbaGTQUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 12:20:53 -0400
Received: by mail-ig0-f173.google.com with SMTP id h18so2111438igc.6
        for <netdev@vger.kernel.org>; Sun, 20 Jul 2014 09:20:53 -0700 (PDT)
In-Reply-To: <CAM_iQpU8P=sgbtOfjZ8QD6maoMCfwoiTgEsiEVG7M=j3M3v22g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/14 18:15, Cong Wang wrote:
> On Sat, Jul 19, 2014 at 3:07 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:

>
> gen_new_kid() is called only when handle is not specified by user.
>

Ok, thanks. Please add my sign-off.

cheers,
jamal
