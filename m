From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 12/14] net: dsa: mv88e6xxx: add port ATU learn
 limit op
Date: Fri, 10 Mar 2017 01:37:58 +0100
Message-ID: <20170310003758.GD22101@lunn.ch>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
 <20170309233324.18539-13-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42788 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751932AbdCJAiB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 19:38:01 -0500
Content-Disposition: inline
In-Reply-To: <20170309233324.18539-13-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 09, 2017 at 06:33:22PM -0500, Vivien Didelot wrote:
> Add a new operation to disable the limiting of learnt MAC addresses.
> 
> Setting such limit is not likely to be used soon, so provide a
> port_disable_learn_limit operation directly. This can be changed later
> for port_set_learn_limit when we'll need it.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
