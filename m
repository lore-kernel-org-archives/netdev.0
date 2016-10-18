From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH -next] net: dsa: mv88e6xxx: fix non static symbol warning
Date: Tue, 18 Oct 2016 17:56:54 +0200
Message-ID: <20161018155654.GD26778@lunn.ch>
References: <1476806017-4290-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48021 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938606AbcJRP5B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 11:57:01 -0400
Content-Disposition: inline
In-Reply-To: <1476806017-4290-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 18, 2016 at 03:53:37PM +0000, Wei Yongjun wrote:
> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warning:
> 
> drivers/net/dsa/mv88e6xxx/chip.c:2866:5: warning:
>  symbol 'mv88e6xxx_g1_set_switch_mac' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
