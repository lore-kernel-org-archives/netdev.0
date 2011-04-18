From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: Driver build-testing (was: [PATCH] net: dm9000: Fix build)
Date: Mon, 18 Apr 2011 17:07:33 +0100
Message-ID: <20110418160732.GE9462@sirena.org.uk>
References: <1303124677-6168-1-git-send-email-broonie@opensource.wolfsonmicro.com> <20110418111203.GB18324@rere.qmqm.pl> <20110418122522.GC9462@sirena.org.uk> <20110418145102.GA2555@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Micha? Miros?aw <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:33815 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754586Ab1DRQHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 12:07:34 -0400
Content-Disposition: inline
In-Reply-To: <20110418145102.GA2555@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2011 at 04:51:02PM +0200, Micha? Miros?aw wrote:

> I wonder if allyesconfig/allmodconfig is supposed to include code that's
> known not to work for a particular architecture.

Well, it's certainly supposed to include things that aren't *useful*
which is more the point here.  all*config is clearly building a
configuration which isn't terribly useful for any particular machine.
