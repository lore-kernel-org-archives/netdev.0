From: Dinh Nguyen <dinguyen@altera.com>
Subject: Re: [RFC] phy: micrel: Convert micrel PHY driver to use OF
Date: Wed, 21 Aug 2013 15:00:48 -0500
Message-ID: <1377115248.1554.20.camel@linux-builds1>
References: <1376412156-3899-1-git-send-email-dinguyen@altera.com>
	 <CACRpkdZkyeA5ExvHQPExNBq5qB1hDHON32TO63BmtVrRxDxhXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Dinh Nguyen <dinh.linux@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	Felipe Balbi <balbi@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Olof Johansson <olof@lixom.net>,
	Rob Herring <rob.herring@calxeda.com>
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe001.messaging.microsoft.com ([216.32.180.184]:22603
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752498Ab3HUUAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 16:00:43 -0400
In-Reply-To: <CACRpkdZkyeA5ExvHQPExNBq5qB1hDHON32TO63BmtVrRxDxhXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-15 at 21:55 +0200, Linus Walleij wrote:
> On Tue, Aug 13, 2013 at 6:42 PM,  <dinguyen@altera.com> wrote:
> 
> > From: Dinh Nguyen <dinguyen@altera.com>
> >
> > Convert the Micrel PHY driver to use OF. This initial patch is only
> > the beginning of an idea to convert the PHY driver to device tree.
> >
> > Signed-of-by: Dinh Nguyen <dinguyen@altera.com>
> 
> This is full of device tree stuff so please copy it to
> devicetree@vger.kernel.org.
> 
> It seems to add quite a few compatible strings so these should
> be added to the bindings doc, or is it already?

No, there is not a bindings doc yet. I was just trying to see if this is
the right approach..

Thanks,
Dinh
> 
> Yours,
> Linus Walleij
> 
