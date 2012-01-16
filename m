From: Alan Cox <alan@linux.intel.com>
Subject: Re: [PATCH] pch_gbe: Use a randomly generated MAC instead of
 failing probe
Date: Mon, 16 Jan 2012 17:02:51 +0000
Message-ID: <20120116170251.3e5d07cd@bob.linux.org.uk>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF47@saturn3.aculab.com>
	<4F1451BD.9030904@linux.intel.com>
	<20120116164424.GA19621@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Darren Hart <dvhart@linux.intel.com>,
	Tomoya MORINAGA <tomoya.rohm@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	netdev@vger.kernel.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120116164424.GA19621@sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> bootloader configuration) - for a lot of applications random
> generation doesn't help that much as entropy is hard to come by.

This is an x86 platform - plenty of entropy from the tsc etc.
