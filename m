From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Corrupt Network Packets -- 3.17-rc5/rc6
Date: Mon, 22 Sep 2014 08:53:43 -0700
Message-ID: <CAM_iQpXQcM2E2oez+nNbbecd25fXqOKNqAfoOgCfQ72-VfBOUA@mail.gmail.com>
References: <201409221130.s8MBUQls003040@clem.clem-digital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pete Clements <clem@clem.clem-digital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201409221130.s8MBUQls003040@clem.clem-digital.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Networking bug report needs to go netdev@)

On Mon, Sep 22, 2014 at 4:30 AM, Pete Clements
<clem@clem.clem-digital.net> wrote:
> Heads up fyi: system is i386 UP.
>
> Started getting some pop3 reception errors from the above system.
> Investigating the problem discovered scp of the mailbox failed
> with "Corrupted MAC on input"
>
> Problem started with rc5, still in rc6. Running rc4 with no
> problem.
>
> Sorry for lack of better definition.


Which driver are you using?
