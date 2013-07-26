From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: Re: [PATCH] fib_rules: add minimum prefix length
Date: Fri, 26 Jul 2013 12:54:22 +0200
Message-ID: <20130726105422.GG10216@zirkel.wertarbyte.de>
References: <20130723220221.GP10216@zirkel.wertarbyte.de>
 <20130724021420.GA10670@order.stressinduktion.org>
 <20130725162931.GX10216@zirkel.wertarbyte.de>
 <20130725181712.GB24007@order.stressinduktion.org>
 <20130725182818.GZ10216@zirkel.wertarbyte.de>
 <CAKTPYJReVfF85wvpbjCF1XREoh3+wzC1baxibZNE1auexcgigA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrew Collins <bsderandrew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:47006 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756225Ab3GZKyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 06:54:23 -0400
Content-Disposition: inline
In-Reply-To: <CAKTPYJReVfF85wvpbjCF1XREoh3+wzC1baxibZNE1auexcgigA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dies schrieb Andrew Collins (bsderandrew@gmail.com):

> I like the idea, but I agree with Hannes that it'd be nice to split
> this out into a fib constraint callback.

Here we go again:
https://github.com/wertarbyte/linux/compare/fib_rule_suppress
