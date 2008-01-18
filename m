From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-2.6.25]  New driver "sfc" for Solarstorm SFC4000 controller - 5th attempt
Date: Fri, 18 Jan 2008 17:16:38 +0000
Message-ID: <20080118171637.GG23117@solarflare.com>
References: <4790D1CD.80500@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pythagoras.zen.co.uk ([212.23.3.140]:48082 "EHLO
	pythagoras.zen.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496AbYARRQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 12:16:41 -0500
Received: from [82.69.137.158] (helo=opal.uk.level5networks.com)
	by pythagoras.zen.co.uk with esmtp (Exim 4.63)
	(envelope-from <bwh@solarflare.com>)
	id 1JFupb-0007t1-OY
	for netdev@vger.kernel.org; Fri, 18 Jan 2008 17:16:39 +0000
Content-Disposition: inline
In-Reply-To: <4790D1CD.80500@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Stonehouse wrote:
<snip>
>  - Improved reliability of I2C operations.
<snip>

This reminds me that Randy Dunlap raised the question of whether we
could integrate with the kernel I2C and SPI systems.  I did some
investigatory work on this but it looked like it would add complexity
and increase our code size.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
