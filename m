From: Pete Clements <clem@clem.clem-digital.net>
Subject: Re: Corrupt Network Packets -- 3.17-rc5/rc6
Date: Mon, 22 Sep 2014 13:24:59 -0400 (EDT)
Message-ID: <201409221724.s8MHOxe5002845@clem.clem-digital.net>
References: <CAM_iQpXQcM2E2oez+nNbbecd25fXqOKNqAfoOgCfQ72-VfBOUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clem@clem.clem-digital.net (Pete Clements),
	linux-kernel@vger.kernel.org (linux-kernel),
	netdev@vger.kernel.org (Linux Kernel Network Developers)
To: xiyou.wangcong@gmail.com (Cong Wang)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXQcM2E2oez+nNbbecd25fXqOKNqAfoOgCfQ72-VfBOUA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Cong Wang
  > <clem@clem.clem-digital.net> wrote:
  > > Heads up fyi: system is i386 UP.
  > >
  > > Started getting some pop3 reception errors from the above system.
  > > Investigating the problem discovered scp of the mailbox failed
  > > with "Corrupted MAC on input"
  > >
  > > Problem started with rc5, still in rc6. Running rc4 with no
  > > problem.
  > >
  > > Sorry for lack of better definition.
  > 
  > 
  > Which driver are you using?
  > 
Here's the output from boot log:

 PCI: setting IRQ 11 as level-triggered
 3c59x 0000:00:0d.0: found PCI INT A -> IRQ 11
 3c59x: Donald Becker and others.
 0000:00:0d.0: 3Com PCI 3c900 Cyclone 10Mbps TPC at d8812000.

-- 
Pete Clements 
