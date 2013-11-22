From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH RFC 5/5] net: macb: Adjust tx_clk when link speed changes
Date: Fri, 22 Nov 2013 11:31:30 -0800
Message-ID: <0f0684eb-c3c1-4fbf-97da-1cd03f0a3a6f@DB8EHSMHS008.ehs.local>
References: <1381795140-10792-1-git-send-email-soren.brinkmann@xilinx.com>
 <1381795140-10792-6-git-send-email-soren.brinkmann@xilinx.com>
 <525CF4AD.1070304@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <525CF4AD.1070304@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Nicolas,

On Tue, Oct 15, 2013 at 09:54:21AM +0200, Nicolas Ferre wrote:
> On 15/10/2013 01:59, Soren Brinkmann :
> >Adjust the ethernet clock according to the negotiated link speed.
> >
> >Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
>=20
> I will need more time to study this one.
>=20
> Moreover, I will have to add the "tx_clk" to every user of this
> driver before switchin to the addition of this clock.

I just wanted to follow up on this. Did you have a chance to look at
this closer?

	Thanks,
	S=C3=B6ren
