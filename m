From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 4/6] net: dsa: remove unused arguments of tagger rcv
Date: Tue, 30 May 2017 16:03:31 -0400
Message-ID: <87r2z6i030.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170530183319.10718-1-vivien.didelot@savoirfairelinux.com> <20170530183319.10718-5-vivien.didelot@savoirfairelinux.com> <b31811c6-d019-da1f-9df0-0ad00264204b@gmail.com> <87shjmyv9m.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <a01d88e5-5bb2-dd83-e416-daa6ebe0fb66@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a01d88e5-5bb2-dd83-e416-daa6ebe0fb66@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli <f.fainelli@gmail.com> writes:

>> Is orig_dev really needed in the tagging implementation, or only in the
>> layer above? (dsa_slave_xmit and dsa_switch_rcv.)
>
> It's needed:
>
> https://github.com/ffainelli/linux/commits/switch-tag
> https://github.com/ffainelli/linux/commit/61f9ca70dd21bb8c1615f959934cd0ce80a2f3ce

Patch dropped!
