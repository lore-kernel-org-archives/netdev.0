From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/2] net: dsa: lan9303: Simplify lan9303_xxx_packet_processing() usage
Date: Mon, 31 Jul 2017 11:15:19 -0400
Message-ID: <87a83kk588.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170731113355.4284-1-privat@egil-hjelmeland.no> <20170731113355.4284-3-privat@egil-hjelmeland.no> <87379c4sfe.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <3207fcff-8318-9b17-c546-026ab1a1511b@egil-hjelmeland.no> <87o9s01xb3.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <3eafb133-2b39-a1c5-6c01-917799fb6320@egil-hjelmeland.no> <87shhc6471.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <6bc09c91-14b7-f28d-4f1f-f243f12b2940@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6bc09c91-14b7-f28d-4f1f-f243f12b2940@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Egil,

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

>> It is indeed out of scope. You may want to add a first commit "net: dsa:
>> lan9303: introduce LAN9303_NUM_PORTS" for instance.
>
> In a later series I assume? Or is allowed to add patches to a series
> under review?

If it makes sense to include this first limit patch in this series under
review, you can totally add it. A simple "Changes in v2: - add
LAN9303_NUM_PORTS" list in the cover letter will do the job.


Thanks,

        Vivien
