From: Andri Yngvason <andri.yngvason@marel.com>
Subject: Re: [PATCH v5 2/5] can: kvaser_usb: Consolidate and unify state change
 handling
Date: Thu, 22 Jan 2015 10:14:47 +0000
Message-ID: <20150122101447.25198.24222@shannon>
References: <20141223154654.GB6460@vivalin-002> <20150120214409.GA16828@linux>
 <20150120214537.GB16828@linux> <20150121162025.2933.13836@shannon>
 <54C02F4B.80206@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	"Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <54C02F4B.80206@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Marc Kleine-Budde (2015-01-21 22:59:23)
> On 01/21/2015 05:20 PM, Andri Yngvason wrote:
> > Marc, could you merge the "move bus_off++" patch before you merge this so that I
> > won't have to incorporate this patch-set into it?
> 
> ...included in the lastest pull-request to David. Use
> tags/linux-can-next-for-3.20-20150121 of the can-next repo as you new base.
> 

Thanks!

--
Andri
