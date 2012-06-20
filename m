From: Federico Vaga <federico.vaga@gmail.com>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Wed, 20 Jun 2012 11:03:08 +0200
Message-ID: <3170667.1PZa2330KE@harkonnen>
References: <20120620133348.a9ff31a72ffd11818f574fe3@canb.auug.org.au> <D5ECB3C7A6F99444980976A8C6D896384FAA275CBE@EAPEX1MAIL1.st.com> <4FE18A5E.204@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Bhupesh SHARMA <bhupesh.sharma@st.com>,
	David Miller <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Giancarlo ASNAGHI <giancarlo.asnaghi@st.com>,
	"wg@grandegger.com" <wg@grandegger.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FE18A5E.204@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I think the driver is currently used/tested only on ARM only, so what
> about adding a HAVE_CLK dependency, until Viresh Kumar's patches are
> available in net-next. Later we can remove it.

This driver is tested only on an x86 with AMBA peripherals on PCI. We 
are developing the clk side for this new platform. 

-- 
Federico Vaga
