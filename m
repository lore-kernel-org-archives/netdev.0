From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] ARM: dts: vf610-zii-dev-rev-b: change switch2 label
Date: Tue, 28 Mar 2017 15:18:43 -0400
Message-ID: <87k279xl9o.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170328191126.18773-1-vivien.didelot@savoirfairelinux.com> <b4cfecb4-af1c-1ead-b12f-14c20af0f3ac@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b4cfecb4-af1c-1ead-b12f-14c20af0f3ac@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 03/28/2017 12:11 PM, Vivien Didelot wrote:
>> Rename the switch2@0 label of the switch2 node to switch@0 to respect
>> the general unit@address DTS rule, and be consistent with the other
>> switch nodes of the DTS file.
>> 
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>
> This looks good, but you certainly want the ARM SoC maintainer for that
> platform to be able to pick that change through his tree, can you
> resubmit with the proper CC list?

Hum it looks like I'm still not confortable with who is going to pick
minor changes to DTS files... Will do, thanks!

      Vivien
