From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH V2 2/3] net-next: dsa: add multi cpu port support
Date: Tue, 30 May 2017 15:50:37 -0400
Message-ID: <87vaoiyvhu.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170530104419.6052-1-john@phrozen.org> <20170530104419.6052-2-john@phrozen.org> <87inki5dsu.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: John Crispin <john@phrozen.org>, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87inki5dsu.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:

>> +	int port_cpu = ds->ports[port].upstream;
>
> ds->ports[port] is p->dp.

I misread this part, p is not yet allocated in that chunk, please ignore
this one comment ;-)

Thanks,

        Vivien
