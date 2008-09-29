From: "Matti Linnanvuori" <mattilinn@gmail.com>
Subject: Re: [patch v2] net: add Gigabit Ethernet Switch for PCI driver gesp
Date: Mon, 29 Sep 2008 14:55:11 +0300
Message-ID: <ca0148c30809290455y560a2a84iab0275593355f28e@mail.gmail.com>
References: <ca0148c30807210325j3cbff1f6i59404171089c82f5@mail.gmail.com>
	 <489A95EA.8000702@pobox.com>
	 <ca0148c30808120512re132edercfebbbd4c97fc2dc@mail.gmail.com>
	 <48CC5ACB.6030203@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:30099 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763AbYI2LzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 07:55:13 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2066147wfd.4
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2008 04:55:12 -0700 (PDT)
In-Reply-To: <48CC5ACB.6030203@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/9/14 Jeff Garzik <jgarzik@pobox.com>:
> Need a little bit more information here.
>
> How close is this hardware to e1000?

It uses e1000 interfaces as components.

> Is this driver really from Intel, as the contact information implies?

The driver is not from Intel as such but it mostly copies Intel's e1000 code.

> Is there documentation on the hardware anywhere?

Yeah. I don't have the copyright now, though...
