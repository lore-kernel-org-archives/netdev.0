From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: add regs attribute to phy device for user diagnose
Date: Sat, 14 Jan 2017 17:24:53 +0100
Message-ID: <20170114162453.GB1072@lunn.ch>
References: <1484361992-30591-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: yuan linyu <cugyly@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60199 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751333AbdANQZH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 14 Jan 2017 11:25:07 -0500
Content-Disposition: inline
In-Reply-To: <1484361992-30591-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 14, 2017 at 10:46:31AM +0800, yuan linyu wrote:
> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> if phy device have register(s) configuration problem,
> user can use this attribute to diagnose.
> this feature need phy driver maintainer implement.

what is wrong with mii-tool -vv ?

     Andrew
