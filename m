From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] mv643xx_eth: device tree bindings
Date: Mon, 06 May 2013 11:38:00 -0400 (EDT)
Message-ID: <20130506.113800.203598940932244298.davem@davemloft.net>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
	<1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, rob.herring@calxeda.com, rob@landley.net,
	buytenh@wantstofly.org, florian@openwrt.org,
	arnaud.patard@rtp-net.org, linux@arm.linux.org.uk,
	jason@lakedaemon.net, andrew@lunn.ch, moinejf@free.fr,
	thomas.petazzoni@free-electrons.com, simon.guinot@sequanux.org,
	jm@lentin.co.uk, michael@walle.cc, hutter.eric@gmail.com,
	josh.coombs@gmail.com, w@1wt.eu, gmbnomis@gmail.com,
	alanbutty12@gmail.com, nigel@nobiscuit.com,
	valentin.longchamp@keymile.com, s.peter@mpl.ch, arno@natisbad.org,
	iwamatsu@nigauri.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Two things:

1) None of your postings make the mailing lists because your CC: line is
   too large, and we block large ones because those are %99 of SPAM.

   It really isn't reasonable to CC: so many people, and I do understand
   that you're just sifting email addresses from MAINTAINERS or whatever,
   but just use the appropriate mailing lists and the absolute most direct
   developer(s).  Probably just the person who you believe should apply
   this patch.

2) Networking feature patch submissions are closed, as per:

	http://marc.info/?l=linux-netdev&m=136730964130303&w=2

   Therefore please resubmit this after the merge window is closed
   and I have explicitly announced that the net-next tree is open again
   for submissions.

Thanks.
