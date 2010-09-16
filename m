From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Re: 2.6.36-rc4/iwl: warning triggered in net/mac80211/scan.c:266
Date: Thu, 16 Sep 2010 22:05:53 +0200
Message-ID: <201009162205.54034.maciej.rutecki@gmail.com>
References: <20100914142814.GA8744@redhat.com>
Reply-To: maciej.rutecki@gmail.com
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Reinette Chatre <reinette.chatre@intel.com>,
	"Wey-Yi Guy" <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100914142814.GA8744@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On wtorek, 14 wrze=C5=9Bnia 2010 o 16:28:15 Michael S. Tsirkin wrote:
> I am running 2.6.36-rc4 on T60 with an iwlagn wireless card:
> 03:00.0 Network controller: Intel Corporation PRO/Wireless 5100 AGN
> [Shiloh] Network Connection
>=20
> I was compiling a large file which stressed the box heavily, and the
> following warning in net/mac80211/scan.c triggered:

I created a Bugzilla entry at=20
https://bugzilla.kernel.org/show_bug.cgi?id=3D18692
for your bug report, please add your address to the CC list in there, t=
hanks!

--=20
Maciej Rutecki
http://www.maciek.unixy.pl
