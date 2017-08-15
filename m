From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 09/11] net: dsa: debugfs: add port mdb
Date: Tue, 15 Aug 2017 10:38:53 -0700
Message-ID: <9d2f285c-12ef-cce5-5113-60ebfaac7b51@gmail.com>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
 <20170814222242.10643-10-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Maxime Hadjinlian <maxime@devialet.com>,
        Chris Healy <cphealy@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Stefan Eichenberger <eichest@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>,
        Juergen Borleis <jbe@pengutronix.de>,
        Tobias Waldekranz <tobias@waldekranz.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814222242.10643-10-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/14/2017 03:22 PM, Vivien Didelot wrote:
> Add a debug filesystem "mdb" entry to query a port's hardware MDB
> entries through the .port_mdb_dump switch operation.
> 
> This is really convenient to query directly the hardware or inspect DSA
> or CPU links, since these ports are not exposed to userspace.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
