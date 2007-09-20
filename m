From: Bill Fink <billfink@mindspring.com>
Subject: Re: e1000 driver and samba
Date: Wed, 19 Sep 2007 22:51:05 -0400
Message-ID: <20070919225105.1e80e91d.billfink@mindspring.com>
References: <780b6f780709171158h1016b6c2kfbc977b4ea7c715c@mail.gmail.com>
	<36D9DB17C6DE9E40B059440DB8D95F5203592D77@orsmsx418.amr.corp.intel.com>
	<20070918020358.d50653d5.billfink@mindspring.com>
	<ygfps0g8lj0.fsf@janus.isnogud.escape.de>
	<82k5qoxfbk.fsf@mid.bfk.de>
	<780b6f780709180932j5944b927p44ace42833e0230b@mail.gmail.com>
	<08FE5CC30C9A3F41BF819A502CF7BF6E02045257@fmsmsx411.amr.corp.intel.com>
	<780b6f780709190753qd52d099id937a6c75e5d560e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Florian Weimer" <fweimer@bfk.de>,
	"Urs Thuermann" <urs@isnogud.escape.de>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"James Chapman" <jchapman@katalix.com>, netdev@vger.kernel.org
To: "L F" <lfabio.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:59882 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750939AbXITCvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 22:51:23 -0400
In-Reply-To: <780b6f780709190753qd52d099id937a6c75e5d560e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007, L F wrote:

> I have one further question: what should I be doing with the TSO and
> flow control? As of now, TSO is on but flow control is off.
> I'd like to thank everyone who helped and I'll be trying to see if the
> realtek integrated NIC works next.

Just my personal opinion, but unless you want to do more testing,
since you now seem to have a working setup, I would tend to leave
it the way it is.

						-Bill
