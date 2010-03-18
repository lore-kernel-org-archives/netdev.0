From: David Miller <davem@davemloft.net>
Subject: Re: e1000e: Fix build with CONFIG_PM disabled.
Date: Wed, 17 Mar 2010 23:11:40 -0700 (PDT)
Message-ID: <20100317.231140.193726740.davem@davemloft.net>
References: <201003172339.15494.rjw@sisk.pl>
	<1268869036.19191.92.camel@jbrandeb-mobl3.amr.corp.intel.com>
	<201003180051.23075.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, emil.s.tantilov@intel.com,
	netdev@vger.kernel.org, bruce.w.allan@intel.com,
	jeffrey.t.kirsher@intel.com
To: rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54946
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751204Ab0CRGLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 02:11:18 -0400
In-Reply-To: <201003180051.23075.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Thu, 18 Mar 2010 00:51:22 +0100

> You'd have to "git reset --hard" to the commit preceding them and then apply
> the combo patch.

Right, which I'm not going to do because it'll screw
up whoever has the net-next-2.6 tree already.
