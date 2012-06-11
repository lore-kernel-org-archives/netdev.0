From: Federico Vaga <federico.vaga@gmail.com>
Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Mon, 11 Jun 2012 15:18:02 +0200
Message-ID: <CAH5GJ0qgQJZwO8xn-zkMA_mMhVM=uCjuCZjd8EbJr0NyE6i+tQ@mail.gmail.com>
References: <331ABD5ECB02734CA317220B2BBEABC13E9CB18A@DBDE01.ent.ti.com>
 <4FCE07EE.40003@pengutronix.de> <D5ECB3C7A6F99444980976A8C6D896384FA5EC4DFC@EAPEX1MAIL1.st.com>
 <4FC135C6.5030206@grandegger.com> <1677842.Pq7naXsvrI@harkonnen>
 <D5ECB3C7A6F99444980976A8C6D896384FA5EC4B37@EAPEX1MAIL1.st.com>
 <3650428.HarNR9HfNF@harkonnen> <20120605131337.GA15432@mail.gnudd.com>
 <20120605133013.GA16108@mail.gnudd.com> <20120605165008.GA21871@mail.gnudd.com>
 <D5ECB3C7A6F99444980976A8C6D896384FA5EC4E62@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "rubini@gnudd.com" <rubini@gnudd.com>,
	"anilkumar@ti.com" <anilkumar@ti.com>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"wg@grandegger.com" <wg@grandegger.com>,
	Giancarlo ASNAGHI <giancarlo.asnaghi@st.com>,
	"alan@linux.intel.com" <alan@linux.intel.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Bhupesh SHARMA <bhupesh.sharma@st.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384FA5EC4E62@EAPEX1MAIL1.st.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

How we proceed?
I submit my c_can_pci.c as a separated module, we create a
c_can_platform_common.c,
or we are thinking about a generic c_can.c as plaftorm driver?

-- 
Federico Vaga
