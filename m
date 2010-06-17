From: Christoph Fritz <chf.fritz@googlemail.com>
Subject: Re: mpd client timeouts (bisected) 2.6.35-rc3
Date: Thu, 17 Jun 2010 17:05:11 +0200
Message-ID: <1276787111.2970.1.camel@lovely.krouter>
References: <20100612102802.GA1782@arch.tripp.de>
	 <20100612.145835.123986343.davem@davemloft.net>
	 <4C149147.3080808@intel.com> <4C15414E.5090201@intel.com>
	 <20100613205922.GA1806@arch.tripp.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, alex.shi@intel.com,
	tim.c.chen@intel.com
To: "markus@trippelsdorf.de" <markus@trippelsdorf.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100613205922.GA1806@arch.tripp.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2010-06-13 at 22:59 +0200, markus@trippelsdorf.de wrote:
> On Sun, Jun 13, 2010 at 01:36:30PM -0700, John Fastabend wrote:

> > [PATCH] net: fix deliver_no_wcard regression on loopback device
> 
> This solves the problem here. Thanks.

here too

Tested-by: Christoph Fritz <chf.fritz@googlemail.com>
