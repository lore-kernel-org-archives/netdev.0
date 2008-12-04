From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m
	driver v2
Date: Thu, 04 Dec 2008 10:01:49 +0100
Message-ID: <1228381309.3197.17.camel@Friederike-PC.hoffi>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <200812021810.59279.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org,
	Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:42921 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755218AbYLDJCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 04:02:35 -0500
In-Reply-To: <200812021810.59279.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-12-02 at 18:10 -0800, Inaky Perez-Gonzalez wrote:

> First two ones I plan to tackle ASAP. The dynamic_printk() stuff might take
> longer and I was wondering if you would be ok with changing that post-29 in
> case I were about to miss the merge window (got a few very busy weeks
> ahead of me).

Fine with me, I guess, I don't even know if the dynprintk is applicable
(though I'd rather see you make it work if it isn't than add yet another
huge debug macro file :) )

johannes

