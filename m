From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v1 RFC 5/7] Break KSZ9477 DSA driver into two files
Date: Mon, 9 Oct 2017 13:01:35 -0700
Message-ID: <76958b73-763c-e004-f489-fa81386b6950@gmail.com>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
 <1507321985-15097-6-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tristram.Ha@microchip.com, Andrew Lunn <andrew@lunn.ch>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507321985-15097-6-git-send-email-Tristram.Ha@microchip.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/06/2017 01:33 PM, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>
> 
> Break KSZ9477 DSA driver into two files in preparation to add more KSZ
> switch drivers.
> Add common functions in ksz_common.h so that other KSZ switch drivers
> can access code in ksz_common.c.
> Add ksz_spi.h for common functions used by KSZ switch SPI drivers.
> 
> Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
