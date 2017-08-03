From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next 4/5] net: dsa: lan9303: Rename
 lan9303_xxx_packet_processing()
Date: Thu, 3 Aug 2017 15:28:49 +0200
Message-ID: <20170803132849.GD15018@lunn.ch>
References: <20170803094507.3439-1-privat@egil-hjelmeland.no>
 <20170803094507.3439-5-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170803094507.3439-5-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2017 at 11:45:06AM +0200, Egil Hjelmeland wrote:
> The lan9303_enable_packet_processing, lan9303_disable_packet_processing
> functions operate on port, so the names should reflect that.
> And to align with lan9303_disable_processing(), rename:
> 
> lan9303_enable_packet_processing -> lan9303_enable_processing_port
> lan9303_disable_packet_processing -> lan9303_disable_processing_port
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>


Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
