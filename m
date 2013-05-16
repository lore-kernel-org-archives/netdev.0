From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCH 00/33] devm improvement series, part 1, take 2
Date: Thu, 16 May 2013 12:29:19 -0600
Message-ID: <5195257F.3060309@wwwdotorg.org>
References: <1368702961-4325-1-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org,
 linux-usb@vger.kernel.org, Liam Girdwood <lgirdwood@gmail.com>,
 Alexander Shishkin <alexander.shishkin@linux.intel.com>,
 Viresh Kumar <viresh.kumar@linaro.org>,
 Linus Walleij <linus.walleij@linaro.org>, Matt Mackall <mpm@selenic.com>,
 linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org,
 Jaroslav Kysela <perex@perex.cz>, linux-ide@vger.kernel.org,
 netdev@vger.kernel.org, linux-mtd@lists.infradead.org,
 linux-i2c@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>,
 Wan ZongShun <mcuos.com@gmail.com>, ac100@lists.launchpad.net,
 devel@driverdev.osuosl.org, Kukjin Kim <kgene.kim@samsung.com>,
 Russell King <linux@arm.linux.org.uk>,
 Herbert Xu <herbert@gondor.apana.org.au>,
 Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
 "Rafael J. Wysocki" <rjw@sisk.pl>, cpufreq@vger.kernel.org,
 Eduardo Valentin <eduardo.v
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1368702961-4325-1-git-send-email-wsa@the-dreams.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel/>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: "devel" <devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On 05/16/2013 05:15 AM, Wolfram Sang wrote:
> Lately, I have been experimenting how to improve the devm interface to make
> writing device drivers easier and less error prone while also getting rid of
> its subtle issues. I think it has more potential but still needs work and
> definately conistency, especiall in its usage.
...

The Tegra parts in patches 4, 5, 8, 15, 16, 17, 29 all,
Acked-by: Stephen Warren <swarren@nvidia.com>
