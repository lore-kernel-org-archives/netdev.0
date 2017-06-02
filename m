From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net] net: dsa: Move dsa_switch_{suspend,resume} out of legacy.c
Date: Fri, 02 Jun 2017 10:46:00 -0400
Message-ID: <87d1amqwgn.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170602025304.14298-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170602025304.14298-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli <f.fainelli@gmail.com> writes:

> dsa_switch_suspend() and dsa_switch_resume() are functions that belong in
> net/dsa/dsa.c and are not part of the legacy platform support code.
>
> Fixes: a6a71f19fe5e ("net: dsa: isolate legacy code")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
