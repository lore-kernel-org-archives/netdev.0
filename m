From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [RFC] phy: micrel: Convert micrel PHY driver to use OF
Date: Thu, 15 Aug 2013 21:55:48 +0200
Message-ID: <CACRpkdZkyeA5ExvHQPExNBq5qB1hDHON32TO63BmtVrRxDxhXw@mail.gmail.com>
References: <1376412156-3899-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dinh Nguyen <dinh.linux@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	Felipe Balbi <balbi@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Olof Johansson <olof@lixom.net>,
	Rob Herring <rob.herring@calxeda.com>
To: Dinh Nguyen <dinguyen@altera.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:53095 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757631Ab3HOTzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 15:55:49 -0400
Received: by mail-ob0-f180.google.com with SMTP id up14so1269095obb.39
        for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 12:55:48 -0700 (PDT)
In-Reply-To: <1376412156-3899-1-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 13, 2013 at 6:42 PM,  <dinguyen@altera.com> wrote:

> From: Dinh Nguyen <dinguyen@altera.com>
>
> Convert the Micrel PHY driver to use OF. This initial patch is only
> the beginning of an idea to convert the PHY driver to device tree.
>
> Signed-of-by: Dinh Nguyen <dinguyen@altera.com>

This is full of device tree stuff so please copy it to
devicetree@vger.kernel.org.

It seems to add quite a few compatible strings so these should
be added to the bindings doc, or is it already?

Yours,
Linus Walleij
