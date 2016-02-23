From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCHv2 3/4] ARM: tegra: use build-in device properties with
 rfkill_gpio
Date: Tue, 23 Feb 2016 21:39:05 +0100
Message-ID: <1456259945.9910.25.camel@sipsolutions.net>
References: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com>
	 <2463567.tt0f0ingYr@wuerfel> <2927215.6IlWnjRTgT@fb07-iapwap2>
	 <3466361.DVRahbqhfF@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thierry Reding <thierry.reding@gmail.com>,
	Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org,
	Alexandre Courbot <gnurou@gmail.com>,
	Stephen Warren <swarren@wwwdotorg.org>
To: Arnd Bergmann <arnd@arndb.de>, Marc Dietrich <marvin24@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3466361.DVRahbqhfF@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-02-23 at 16:06 +0100, Arnd Bergmann wrote:
>=C2=A0
> Does rfkill always have a separate device in the Linux driver model?

Yes, the rfkill core code registers and adds one in the rfkill class.

> johannes
