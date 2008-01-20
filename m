From: Frans Pop <elendil@planet.nl>
Subject: Re: 2.6.24 regression: reference count leak in PPPoE
Date: Sun, 20 Jan 2008 21:14:32 +0100
Message-ID: <E1JGgYq-0005Rd-2x@faramir.fjphome.nl>
References: <200801202053.30386.ak@suse.de>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hpsmtp-eml18.kpnxchange.com ([213.75.38.118]:42434 "EHLO
	hpsmtp-eml18.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754734AbYATUOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 15:14:35 -0500
In-reply-To: <200801202053.30386.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> My workstation running 2.6.24-rc8 just hung during shutdown with an
> endless (or rather I didn't wait more than a few minutes) loop of
> 
> unregister_netdev: waiting for ppp-device to become free. Usage count = 1

Same as http://lkml.org/lkml/2008/1/20/27? See also follow-up to that.

Cheers,
FJP
