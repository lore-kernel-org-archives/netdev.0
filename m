From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH RFC 0/6] Modify KSZ9477 DSA driver in preparation to add other KSZ switch drivers.
Date: Fri, 08 Sep 2017 09:30:30 -0400
Message-ID: <87lglpz5ah.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218B7@CHN-SV-EXMX02.mchp-main.com> <93AF473E2DA327428DE3D46B72B1E9FD411219F8@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Tristram.Ha@microchip.com, andrew@lunn.ch, muvarov@gmail.com,
        pavel@ucw.cz, nathan.leigh.conrad@gmail.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD411219F8@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tristram,

Tristram.Ha@microchip.com writes:

> From: Tristram Ha <Tristram.Ha@microchip.com>
>
> This series of patches is to modify the original KSZ9477 DSA driver so that other KSZ switch drivers can be added and use the common code.

Please see Documentation/process/submitting-patches.rst. Use a correct
formatting for the messages, and send you patchset as a thread.

> This patch set is against net-next.

The net subsystem is somehow special. Please see
Documentation/networking/netdev-FAQ.txt. The tree must be indicated in
the subject prefix of the patch series.


Thanks,

        Vivien
