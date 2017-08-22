From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] ARM: dts: rk3228-evb: Fix the compiling error
Date: Tue, 22 Aug 2017 21:52:51 +1000
Message-ID: <20170822215251.2125440b@canb.auug.org.au>
References: <1503393865-7975-1-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: David Wu <david.wu@rock-chips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:44507 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932577AbdHVLwy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 07:52:54 -0400
In-Reply-To: <1503393865-7975-1-git-send-email-david.wu@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Thanks.

On Tue, 22 Aug 2017 17:24:25 +0800 David Wu <david.wu@rock-chips.com> wrote:
>
> This patch solves the following error:
> arch/arm/boot/dts/rk3228-evb.dtb: ERROR (phandle_references): Reference to non-existent node or label "phy0"
> 
> Fixess db40f15b53e4 ("ARM: dts: rk3228-evb: Enable the integrated PHY for gmac")
> Signed-off-by: David Wu <david.wu@rock-chips.com>

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>

-- 
Cheers,
Stephen Rothwell
