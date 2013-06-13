From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3] ethernet/arc/arc_emac - Add new driver
Date: Thu, 13 Jun 2013 21:42:31 +0200
Message-ID: <20130613194231.GA11949@electric-eye.fr.zoreil.com>
References: <1371134239-4531-1-git-send-email-abrodkin@synopsys.com>
 <CAHp75Vf4zjtebbaQMp4L0EmUPDVyrNPfvLODo7gHBuBEsWmZeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Devicetree Discuss <devicetree-discuss@lists.ozlabs.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHp75Vf4zjtebbaQMp4L0EmUPDVyrNPfvLODo7gHBuBEsWmZeA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Shevchenko <andy.shevchenko@gmail.com> :
[...]
> I just realize you are using circular buffer here. What about to use
> them with linux' native framework? Documentation/circular-buffers.txt

It's almost unused in drivers/net. I won't mind if it stays this way.

-- 
Ueimor
