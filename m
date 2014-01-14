From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: pull-request: can-next 2014-01-11
Date: Tue, 14 Jan 2014 23:01:56 +0300
Message-ID: <52D597B4.7020607@cogentembedded.com>
References: <52D191E2.8040703@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52D191E2.8040703@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01/11/2014 09:48 PM, Marc Kleine-Budde wrote:

> Hello David,

> this is a pull request of three patches for net-next/master.

> Oleg Moroz added support for a new PCI card to the generic SJA1000 PCI
> driver, Guenter Roeck's patch limits the flexcan driver to little
> endian arm (and powerpc) and I fixed a sparse warning found by the
> kbuild robot in the ti_hecc driver.

    What about the rewritten Renesas R-Car CAN driver? Is there a chance to 
get it into 3.14-rc1 now that we've missed 3.13-rc1? I've sent it at the very 
end of December, and have got no feedback still...

> regards,
> Marc

WBR, Sergei

