From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH] DSA support for Micrel KSZ8895
Date: Sun, 27 Aug 2017 22:03:10 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B0BF9C@CHN-SV-EXMX02.mchp-main.com>
References: <20170816075524.GA18532@amd> <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>,<20170827123658.GA727@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Tristram.Ha@micrel.com>, <andrew@lunn.ch>
To: <pavel@denx.de>, <nathan.leigh.conrad@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170827123658.GA727@amd>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel,

Thanks for update and sorry about email format (due to web-access version)
I'll do review when getting back to office later this week.

- Woojung
________________________________________
From: Pavel Machek [pavel@denx.de]
Sent: Sunday, August 27, 2017 8:36 AM
To: Woojung Huh - C21699; nathan.leigh.conrad@gmail.com
Cc: vivien.didelot@savoirfairelinux.com; f.fainelli@gmail.com; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Tristram.Ha@micrel.com; andrew@lunn.ch; pavel@denx.de
Subject: [PATCH] DSA support for Micrel KSZ8895

Hi!

So I fought with the driver a bit more, and now I have something that
kind-of-works.

"great great hack" belows worries me.

Yeah, disabled code needs to be removed before merge.

No, tag_ksz part probably is not acceptable. Do you see solution
better than just copying it into tag_ksz1 file?

Any more comments, etc?

Help would be welcome.
