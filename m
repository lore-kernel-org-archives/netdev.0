From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] regmap: only call custom reg_update_bits() if reg
 is marked volatile
Date: Tue, 06 Oct 2015 06:25:08 -0700 (PDT)
Message-ID: <20151006.062508.168154086334967576.davem@davemloft.net>
References: <20151005.232956.105884641412802470.davem@davemloft.net>
	<20151006101305.GG12635@sirena.org.uk>
	<ABC562FD-5DE5-452E-8DE6-1C436E37E8BE@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: broonie@kernel.org, jon@ringle.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jringle@gridpoint.com
To: jonringle@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46765 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbbJFNJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 09:09:27 -0400
In-Reply-To: <ABC562FD-5DE5-452E-8DE6-1C436E37E8BE@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Ringle <jonringle@gmail.com>
Date: Tue, 6 Oct 2015 08:50:43 -0400

> 4) David should then merge the regmap for-next branch into net-next

Nope, this doesn't work at all.

It is my tree which people depend upon, not the other way around.
