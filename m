From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] fix packet loss and massive ping spikes with PPP
 multi-link
Date: Fri, 26 Mar 2010 09:59:29 -0700 (PDT)
Message-ID: <20100326.095929.04683456.davem@davemloft.net>
References: <2d460de71003260850x7f90d04cy79ac853464108182@mail.gmail.com>
	<20100326160226.0159ac3b@lxorguk.ukuu.org.uk>
	<v2v2d460de71003260939w4877df7em9e3084a315b0962f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: richih.mailinglist@gmail.com
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <v2v2d460de71003260939w4877df7em9e3084a315b0962f@mail.gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Hartmann <richih.mailinglist@gmail.com>
Date: Fri, 26 Mar 2010 17:39:27 +0100

> At least the last-level support of Telefonica and QSC was definite
> and adamant about not enabling fragmentation on _any_ PPP
> multi-link, ever.

I'm sure we can find just as many counter examples.

I doubt we'll ever be able to change the default here,
sorry.
