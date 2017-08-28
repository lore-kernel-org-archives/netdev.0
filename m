From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 03/10] net: dsa: debugfs: add tag_protocol
Date: Mon, 28 Aug 2017 22:16:45 +0200
Message-ID: <20170828201645.GB1870@lunn.ch>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828191748.19492-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170828191748.19492-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 28, 2017 at 03:17:41PM -0400, Vivien Didelot wrote:
> Add a debug filesystem "tag_protocol" entry to query the switch tagging
> protocol through the .get_tag_protocol operation.
> 
>     # cat switch1/tag_protocol
>     EDSA
> 
> To ease maintenance of tag protocols, add a dsa_tag_protocol_name helper
> to the public API which to convert a tag protocol enum to a string.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
