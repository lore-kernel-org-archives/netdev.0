From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Add Qualcomm Gobi 2000 driver.
Date: Tue, 28 Sep 2010 18:16:51 +0100
Message-ID: <1285694211.2282.6.camel@achroite.uk.solarflarecom.com>
References: <20100928171026.GB6083@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dbrownell@users.sourceforge.net,
	mjg59@srcf.ucam.org, jglasgow@google.com, msb@google.com,
	olofj@google.com
To: Elly Jones <ellyjones@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:30407 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151Ab0I1RQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 13:16:55 -0400
In-Reply-To: <20100928171026.GB6083@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-09-28 at 13:10 -0400, Elly Jones wrote:
> From: Elizabeth Jones <ellyjones@google.com>
> 
> This driver is a rewrite of the original Qualcomm GPL driver, released as part
> of Qualcomm's "Code Aurora" initiative. The driver has been transformed into
> Linux kernel style and made to use kernel APIs where appropriate; some bugs have
> also been fixed. Note that the device in question requires firmware and a
> firmware loader; the latter has been written by mjg (see
> http://www.codon.org.uk/~mjg59/gobi_loader/).
[...]

You should run this through checkpatch.pl and fix the style errors it
highlights.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

