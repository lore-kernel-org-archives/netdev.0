From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v7] ethernet/arc/arc_emac - Add new driver
Date: Fri, 21 Jun 2013 15:15:50 +0300
Message-ID: <CAHp75Vf8A7YZGBtna7JAaacnJWq5+q_+m44eO13bChxKj6XZgQ@mail.gmail.com>
References: <1371799241-27771-1-git-send-email-abrodkin@synopsys.com>
	<1371810775.19215.30.camel@joe-AO722>
	<4881796E12491D4BB15146FE0209CE643F5F587E@DE02WEMBXB.internal.synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Perches <joe@perches.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Florian Fainelli <florian@openwrt.org>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4881796E12491D4BB15146FE0209CE643F5F587E@DE02WEMBXB.internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 21, 2013 at 1:53 PM, Alexey Brodkin
<Alexey.Brodkin@synopsys.com> wrote:

[]

> But during compilation on x86 one needs to enable OF. Which will lead to
> compilation errors in other things.

JFYI, x86 has at least one platform with official OF dependency.
Once I actually tried to build kernel for Intel MID with OF enabled
(it required a hack in the arch Kconfig, of course), compiled fine.

--
With Best Regards,
Andy Shevchenko
