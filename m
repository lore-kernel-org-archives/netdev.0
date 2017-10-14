From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v1 RFC 1/7] Replace license with GPL
Date: Sat, 14 Oct 2017 21:41:22 +0200
Message-ID: <20171014194122.GI18578@lunn.ch>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
 <1507321985-15097-2-git-send-email-Tristram.Ha@microchip.com>
 <063D6719AE5E284EB5DD2968C1650D6DD008D3F0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Tristram.Ha@microchip.com'" <Tristram.Ha@microchip.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>,
        "muvarov@gmail.com" <muvarov@gmail.com>,
        "nathan.leigh.conrad@gmail.com" <nathan.leigh.conrad@gmail.com>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>,
        "UNGLinuxDriver@microchip.com" <UNGLinuxDriver@microchip.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
        Arkadi Sharshevsky <arkadis@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD008D3F0@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 09, 2017 at 09:18:16AM +0000, David Laight wrote:
> From: Tristram.Ha@microchip.com
> > Sent: 06 October 2017 21:33
> > Replace license with GPL.
> 
> Don't you need permission from all the people who have updated
> the files in order to make this change?

Hi David

Interesting question.

ksz_9477_reg.h and ksz_spi.c are not a problem, since Woojung Huh is
the only contributor.

ksz_common.c has a MODULE_LICENSE("GPL") so indicating it probably was
intended to the GPL.

However, getting an acked-by from Arkadi Sharshevsky
<arkadis@mellanox.com> would be good.

       Andrew
