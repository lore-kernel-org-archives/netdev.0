From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH] ip: allow using a device "help" (or a prefix thereof)
Date: Fri, 18 Sep 2015 14:06:56 +0200
Message-ID: <20150918120656.GA25381@haze>
References: <55FBCA11.7070604@kristov.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Wilhelm Wijkander <lists@0x5e.se>,
	Vadim Kochan <vadim4j@gmail.com>,
	Leonhard Preis <leonhard@pre.is>
To: Christoph Schulz <develop@kristov.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:57392 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbbIRMQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 08:16:59 -0400
Content-Disposition: inline
In-Reply-To: <55FBCA11.7070604@kristov.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 10:23:45AM +0200, Christoph Schulz wrote:
> Device names that match "help" or a prefix thereof should be allowed anywhere
> a device name can be used. Note that a suitable keyword ("dev" or "name", the
> latter for "ip tunnel") has to be used in these cases to resolve ambiguities.

Lol :D
