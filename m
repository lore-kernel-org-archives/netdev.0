From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next 1/5] net: dsa: lan9303: Change
 lan9303_xxx_packet_processing() port param.
Date: Thu, 3 Aug 2017 15:27:17 +0200
Message-ID: <20170803132717.GA15018@lunn.ch>
References: <20170803094507.3439-1-privat@egil-hjelmeland.no>
 <20170803094507.3439-2-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170803094507.3439-2-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2017 at 11:45:03AM +0200, Egil Hjelmeland wrote:
> lan9303_enable_packet_processing, lan9303_disable_packet_processing()
> Pass port number (0,1,2) as parameter instead of port offset.
> Because other functions in the module pass port numbers.
> And to enable simplifications in following patch.
> 
> Introduce lan9303_write_switch_port().
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
