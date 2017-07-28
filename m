From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/4] net: dsa: lan9303: Multiply by 4 to get MDIO
 register
Date: Fri, 28 Jul 2017 10:02:59 -0700
Message-ID: <37546183-ae5a-b360-0922-dc7e8bc1d79b@gmail.com>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no>
 <20170728151157.28983-3-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728151157.28983-3-privat@egil-hjelmeland.no>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/28/2017 08:11 AM, Egil Hjelmeland wrote:
> lan9303_mdio_write()/_read() must multiply register number by 4 to get
> offset.
> 
> Added some commments to the register definitions.
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
