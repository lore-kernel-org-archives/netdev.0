From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 net-next 4/5] net: dsa: lan9303: Rename
 lan9303_xxx_packet_processing()
Date: Thu, 3 Aug 2017 11:08:27 -0700
Message-ID: <43501074-0e61-01f8-b856-bd22c65cf9e8@gmail.com>
References: <20170803094507.3439-1-privat@egil-hjelmeland.no>
 <20170803094507.3439-5-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170803094507.3439-5-privat@egil-hjelmeland.no>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/03/2017 02:45 AM, Egil Hjelmeland wrote:
> The lan9303_enable_packet_processing, lan9303_disable_packet_processing
> functions operate on port, so the names should reflect that.
> And to align with lan9303_disable_processing(), rename:
> 
> lan9303_enable_packet_processing -> lan9303_enable_processing_port
> lan9303_disable_packet_processing -> lan9303_disable_processing_port
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
