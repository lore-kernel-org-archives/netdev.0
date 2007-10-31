From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 1/14 v2] nes: module and device initialization
Date: Tue, 30 Oct 2007 22:21:58 -0700
Message-ID: <ada8x5jhn9l.fsf@cisco.com>
References: <200710192001.l9JK1U8O021689@neteffect.com>
	<adatzodxxxw.fsf@cisco.com>
	<5E701717F2B2ED4EA60F87C8AA57B7CC078C9670@venom2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <ewg@lists.openfabrics.org>, <general@lists.openfabrics.org>,
	<netdev@vger.kernel.org>
To: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:39574 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117AbXJaFWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 01:22:11 -0400
In-Reply-To: <5E701717F2B2ED4EA60F87C8AA57B7CC078C9670@venom2> (Glenn Grundstrom's message of "Sun, 28 Oct 2007 13:21:30 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Thanks Roland.  Let me know when you have your branch ready.

OK, I pushed out a "neteffect" branch at

    git://git.kernel.org/pub/scm/linux/kernel/git/roland/infiniband.git

This has the driver from your git tree plus some compile fixes and
cleanups (added as separate commits, so you can see what I did).  If
it suits you, let's work against that tree to continue cleaning things
up -- you can send me patches or git pull requests to pick up new things.

 - R.
