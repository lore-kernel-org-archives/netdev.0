From: John Crispin <blogic@openwrt.org>
Subject: Re: rt2x00: Kconfig symbols RALINK_RT288X and RALINK_RT305X
Date: Wed, 13 Mar 2013 12:19:17 +0100
Message-ID: <514060B5.8060301@openwrt.org>
References: <1363165170.3137.182.camel@x61.thuisdomein> <CAOiHx=n4a26z=PS02E2KjD2Y3Pp0P0x-5Ns6WRc-WScNF=EO_Q@mail.gmail.com> <1363169039.3137.186.camel@x61.thuisdomein> <CAOiHx=keYYoCGgHfrSKXOHQQvG1mrt60ems3dcXki1K06MHg2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Bolle <pebolle@tiscali.nl>, Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jonas Gorski <jogo@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOiHx=keYYoCGgHfrSKXOHQQvG1mrt60ems3dcXki1K06MHg2g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/03/13 11:35, Jonas Gorski wrote:
> On 13 March 2013 11:03, Paul Bolle<pebolle@tiscali.nl>  wrote:
>> On Wed, 2013-03-13 at 10:51 +0100, Jonas Gorski wrote:
>>> The actual accepted Kconfig symbol names are different though, so they
>>> should be changed in rt2x00 to match them (SOC_RT288X and SOC_RT305X).
>> Thanks. Note that I could not find an actual Kconfig symbol SOC_RT288X!
> Ah, yes, the inital submission only included RT305X support, not
> RT288X (and neither of the newer chips). These will come later.
>
>> Anyhow, I guess somebody has the (trivial) patch to convert
>> RALINK_RT...X and CONFIG_RALINK_RT...X to their SOC_* equivalents queued
>> for inclusion in v3.9-rcX. Is that correct?
> Yes, that should be everything. John Crispin, anything missing from that?
>
>
> Jonas
>
>
Hi,

I will look into this later this week.

John
