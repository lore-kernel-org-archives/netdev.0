From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/4] net: dsa: lan9303: Fix
 lan9303_detect_phy_setup() for MDIO
Date: Fri, 28 Jul 2017 10:02:30 -0700
Message-ID: <4d0fb236-1fe6-d97d-42de-31af088601cd@gmail.com>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no>
 <20170728151157.28983-2-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728151157.28983-2-privat@egil-hjelmeland.no>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/28/2017 08:11 AM, Egil Hjelmeland wrote:
> Handle that MDIO read with no response return 0xffff.
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
