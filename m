From: =?ISO-8859-2?Q?Arkadiusz_Mi=B6kiewicz?= <a.miskiewicz@gmail.com>
Subject: Re: iwlagn regression in v3.1.5
Date: Thu, 15 Dec 2011 23:12:40 +0100
Message-ID: <CA+MtwOFhaKWzF2abx-b-5grP5vMgDm_LvoBx1yDHUiz-OrP4jA@mail.gmail.com>
References: <4EE4AEF4.2080702@udo.edu>
	<4EE4DB55.4090804@udo.edu>
	<20111211174138.79e51fe8@x220.fritz.box>
	<4EE4E152.2070204@udo.edu>
	<1323627815.1806.19.camel@wwguy-ubuntu>
	<4EE50266.4050208@udo.edu>
	<1323653737.1806.21.camel@wwguy-ubuntu>
	<4EE636B9.1020305@udo.edu>
	<1323807327.7144.6.camel@wwguy-ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrej Gelenberg <andrej.gelenberg@udo.edu>,
	Udo Steinberg <udo@hypervisor.org>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: wwguy <wey-yi.w.guy@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1323807327.7144.6.camel@wwguy-ubuntu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 13, 2011 at 9:15 PM, wwguy <wey-yi.w.guy@intel.com> wrote:
> Hi Andrej,
>
> Could you try this patch and see any differences.

I had a problem with 3.1.5 (3.1.4 was fine) and current Linus git
where I was able to associate with my AP (5GHz) but only icmp was
working and while trying to ssh then all packets (including icmp ones)
started to be dropped.

My card is 5350 AGN [Echo Peak] and this patch makes things working
for me on top of current Linus git, too.

--=20
Arkadiusz Mi=C5=9Bkiewicz =C2=A0 =C2=A0 =C2=A0 =C2=A0PLD/Linux Team
arekm / maven.pl =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0http://ftp.pl=
d-linux.org/
