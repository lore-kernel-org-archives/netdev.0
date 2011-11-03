From: Andy Fleming <afleming@gmail.com>
Subject: Re: [RFC PATCH 17/17] phy_device: Rename phy_start_aneg() to
	phy_start_link()
Date: Thu, 3 Nov 2011 17:51:29 -0500
Message-ID: <CAKWjMd51V-r_t85KvHRGQ=ddu0bWXC05piRhi2WrkqsHTr+WRQ@mail.gmail.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
	<1319144425-15547-18-git-send-email-Kyle.D.Moffett@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	David Decotigny <decot@google.com>, devel@driverdev.osuosl.org,
	Matt Carlson <mcarlson@broadcom.com>,
	Kuninori Morimoto <morimoto.kuninori@renesas.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Mike Frysinger <vapier@gentoo.org>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	Michael Chan <mchan@broadcom.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	John Crispin <blogic@openwrt.org>,
	Richard Cochran <richard.cochran@omicron.at>,
	Ilya Yanok <yanok@emcraft.com>, netdev@vger.kernel.org,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	Christian Dietrich <christian.dietrich@inform
To: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1319144425-15547-18-git-send-email-Kyle.D.Moffett@boeing.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

2011/10/20 Kyle Moffett <Kyle.D.Moffett@boeing.com>:
> The name of the "phy_start_aneg()" function is very confusing, because
> it also handles forced-mode (AUTONEG_DISABLE) links.
>
> Rename the function to phy_start_link() and fix up all users.
>
> Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>

Sounds good to me.

Acked-by: Andy Fleming <afleming@freescale.com>
