From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 04/14] net: dsa: mv88e6xxx: rework ATU Load/Purge
Date: Mon, 13 Mar 2017 10:59:02 -0400
Message-ID: <87y3w9nryh.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com> <20170309233324.18539-5-vivien.didelot@savoirfairelinux.com> <20170310022748.GI22101@lunn.ch> <87zigrzg6s.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <20170311234021.GE15842@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170311234021.GE15842@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> It does result in more patches, more to review, but it is much easier
> to review, because it should be obviously correct. The overall lines
> of code at the end is the same. So overall there is no harm is having
> lots of small patches.

Your concerns are dully noted. I'll do my best to split my upcoming
changes in smaller, easier to review, patches.

Thanks!

        Vivien
