From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 3/3] ethernet: Convert mac address uses of 6 to
 ETH_ALEN
Date: Thu, 01 Aug 2013 14:31:37 -0700 (PDT)
Message-ID: <20130801.143137.331385226409040561.davem@davemloft.net>
References: <20130801210618.GK23006@n2100.arm.linux.org.uk>
	<20130801.141016.1475274289112004539.davem@davemloft.net>
	<CAOesGMhf-2KE1B8_4CGJADCG=ceDFRrDbhTnA56kXYPWoKTScg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, joe@perches.com, sammy@sammy.net,
	grundler@parisc-linux.org, mcuos.com@gmail.com,
	rajesh.borundia@qlogic.com, netdev@vger.kernel.org,
	sony.chacko@qlogic.com, linux-kernel@vger.kernel.org,
	manish.chopra@qlogic.com, pcnet32@frontier.com,
	ron.mercer@qlogic.com, gallatin@myri.com, linux-driver@qlogic.com,
	jitendra.kalsaria@qlogic.com, linux-arm-kernel@lists.infradead.org,
	shahed.shaikh@qlogic.com
To: olof@lixom.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOesGMhf-2KE1B8_4CGJADCG=ceDFRrDbhTnA56kXYPWoKTScg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olof Johansson <olof@lixom.net>
Date: Thu, 1 Aug 2013 14:24:32 -0700

> So, you might as well leave the code alone for now. It's not used on
> fast path, and the system definitely handles unaligned accesses for
> this -- it has for years already.

Fair enough, Joe please respin.
