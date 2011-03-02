From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 00/27] HFI minimal device driver/network driver
Date: Wed, 02 Mar 2011 22:42:24 +0000
Message-ID: <1299105744.4277.35.camel@localhost>
References: <1299100795-9028-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dykmanj@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8330 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516Ab1CBWm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 17:42:28 -0500
In-Reply-To: <1299100795-9028-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-02 at 16:19 -0500, dykmanj@linux.vnet.ibm.com wrote:
[...]
> Patches are against net-2.6 (Is that the correct tree for us to use?).

net-next-2.6 would be the correct tree at the moment.  net-2.6 is
currently destined for 2.6.38 and it is too late to add a driver to
that.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

