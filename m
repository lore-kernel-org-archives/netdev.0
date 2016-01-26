From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCHv2 3/4] ARM: tegra: use build-in device properties
 withrfkill_gpio
Date: Tue, 26 Jan 2016 09:46:56 +0100
Message-ID: <1453798016.2759.5.camel@sipsolutions.net>
References: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com>
	 <1453712629-143317-4-git-send-email-heikki.krogerus@linux.intel.com>
	 <20160125121840.GA20452@ulmo.nvidia.com> <1626364.s6q6eBGYVQ@ax5200p>
	 (sfid-20160125_220148_930415_998CEFCC)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org,
	Alexandre Courbot <gnurou@gmail.com>,
	Stephen Warren <swarren@wwwdotorg.org>
To: Marc Dietrich <marvin24@gmx.de>,
	Thierry Reding <thierry.reding@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1626364.s6q6eBGYVQ@ax5200p> (sfid-20160125_220148_930415_998CEFCC)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-01-25 at 21:59 +0100, Marc Dietrich wrote:
>=C2=A0
> seems to work fine. I wish we could instantiate this from device-tree=
=20
> so we can finially get rid of this file.

That'd be nice - anyone want to propose rfkill DT bindings? :)

johannes
