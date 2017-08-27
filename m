From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] ARM: dts: rk3228-evb: Fix the compiling error
Date: Mon, 28 Aug 2017 08:32:54 +1000
Message-ID: <20170828083254.39430ab3@canb.auug.org.au>
References: <1503393865-7975-1-git-send-email-david.wu@rock-chips.com>
        <20170822215251.2125440b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Wu <david.wu@rock-chips.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:35705 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751352AbdH0Wc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 18:32:57 -0400
In-Reply-To: <20170822215251.2125440b@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave (Miller),

On Tue, 22 Aug 2017 21:52:51 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> Thanks.
> 
> On Tue, 22 Aug 2017 17:24:25 +0800 David Wu <david.wu@rock-chips.com> wrote:
> >
> > This patch solves the following error:
> > arch/arm/boot/dts/rk3228-evb.dtb: ERROR (phandle_references): Reference to non-existent node or label "phy0"
> > 
> > Fixess db40f15b53e4 ("ARM: dts: rk3228-evb: Enable the integrated PHY for gmac")
> > Signed-off-by: David Wu <david.wu@rock-chips.com>  
> 
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>

Ping?

-- 
Cheers,
Stephen Rothwell
