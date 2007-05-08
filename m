From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] myri10ge: support new firmware counters
Date: Tue, 08 May 2007 01:16:43 -0400
Message-ID: <464007BB.80802@garzik.org>
References: <463F9E9E.8000808@ens-lyon.org> <463F9EE5.1060605@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54297 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967890AbXEHFQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:16:45 -0400
In-Reply-To: <463F9EE5.1060605@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Add dropped_pause, dropped_bad_phy, dropped_bad_crc32,
> dropped_unicast_filtered to the set of ethtool counters.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c     |    9 ++++++++-
>  drivers/net/myri10ge/myri10ge_mcp.h |    6 +++++-
>  2 files changed, 13 insertions(+), 2 deletions(-)

applied 1-6, except for the aforementioned patch


