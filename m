From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next 22/27] sctp: add rfc6525 section 5.2.4
Date: Mon, 2 Jan 2017 21:43:14 +0800
Message-ID: <CADvbK_d+wukreaSQPqG0O6rBqbiKoSbsGMVM=Df_m54ZetUwpQ@mail.gmail.com>
References: <470b9f2b5248e0c1870c501f262a1887be66509b.1483269426.git.lucien.xin@gmail.com>
 <201701012026.kWKIK4Hy%fengguang.wu@intel.com> <CADvbK_dV2=uJfoPPMHj1nEYvGKvhszgmHOttN7CVgrPWxb2EeQ@mail.gmail.com>
 <20170101.113213.663892510185061837.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
        network dev <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35394 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756057AbdABNnP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 08:43:15 -0500
In-Reply-To: <20170101.113213.663892510185061837.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 2, 2017 at 12:32 AM, David Miller <davem@davemloft.net> wrote:
> From: Xin Long <lucien.xin@gmail.com>
> Date: Sun, 1 Jan 2017 21:26:47 +0800
>
>> As only when the result is not performed, initial_tsn variables is
>> uninitialized, peer side would ignore this value, so here is also
>> safe.
>
> It doesn't matter if it is "safe" or not, you must fix all of the
> warnings reported by kbuild before your patches will be considered
> for applying.
will fix it in next post. thanks
