From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] ethtool : Add option -L | --set-common to set
 common flags.
Date: Mon, 21 Feb 2011 16:00:57 +0000
Message-ID: <1298304057.2608.39.camel@bwh-desktop>
References: <1294963892-11997-1-git-send-email-maheshb@google.com>
	 <1295390237-27381-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:53088 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755253Ab1BUQBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 11:01:00 -0500
In-Reply-To: <1295390237-27381-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-18 at 14:37 -0800, Mahesh Bandewar wrote:
> This patch adds -L | --set-common option to add / remove common flags which
> includes loopback flag. The -l | --show-common displays the current values
> for these common flags.
[...]

I haven't forgotten this, but I won't apply it until the corresponding
kernel change is applied.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

