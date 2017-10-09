From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH v1 RFC 1/7] Replace license with GPL
Date: Mon, 9 Oct 2017 18:40:15 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD4112EE49@CHN-SV-EXMX02.mchp-main.com>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
 <1507321985-15097-2-git-send-email-Tristram.Ha@microchip.com>
 <063D6719AE5E284EB5DD2968C1650D6DD008D3F0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <muvarov@gmail.com>, <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <andrew@lunn.ch>,
        <f.fainelli@gmail.com>, <pavel@ucw.cz>,
        <ruediger.schmitt@philips.com>
To: <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD008D3F0@AcuExch.aculab.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Tristram.Ha@microchip.com
> > Sent: 06 October 2017 21:33
> > Replace license with GPL.
> 
> Don't you need permission from all the people who have updated
> the files in order to make this change?
> 
> 	David

I am a little confused by your comment.  The 4 original KSZ9477 DSA
driver files were written by Woojung at Microchip Technology Inc.
There was a complaint the "AS IS" license is not exactly GPL.

It should be submitted formally to net-next instead of a RFC, but it
is probably pointless to do that when there is no code change.

I am hoping these drastic changes of KSZ9477 driver can be accepted
so that the patches can be submitted formally to net-next.
