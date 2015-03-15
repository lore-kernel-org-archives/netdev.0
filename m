From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] switchdev: support stp updates on
 stacked netdevices
Date: Sun, 15 Mar 2015 18:33:12 -0400 (EDT)
Message-ID: <20150315.183312.401696632034773662.davem@davemloft.net>
References: <CAE4R7bCvFPE5nPBJ7r41-ZC6=5AUE=gQ7uTy4kTNTZf-xKraVg@mail.gmail.com>
	<20150315191722.GE3518@nanopsycho.orion>
	<CAE4R7bDaBQF8kD1Qi9EJ0pApfCEQeQ1z3DQuZjJXZw55NbmyMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, netdev@vger.kernel.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51249 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbbCOWdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 18:33:14 -0400
In-Reply-To: <CAE4R7bDaBQF8kD1Qi9EJ0pApfCEQeQ1z3DQuZjJXZw55NbmyMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Sun, 15 Mar 2015 13:03:06 -0700

> I'm proposing a simple, permissive solution, with a provision for an
> out on a case-by-case basis.  Right now I don't see any reason to
> special case any middle driver; just let STP state propagate down to
> the port device.

+1
