From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Wed, 20 Apr 2016 15:34:49 +0200
Message-ID: <20160420153449.5dd5fb24@griffin>
References: <20160418.214851.122286645854721047.davem@davemloft.net>
	<20160418.235207.395468709808133833.davem@davemloft.net>
	<1461060543.2766.20.camel@sipsolutions.net>
	<20160419.142324.1774057494079734967.davem@davemloft.net>
	<1461094901.2766.26.camel@sipsolutions.net>
	<5716E123.8040002@cumulusnetworks.com>
	<1461137540.2176.5.camel@sipsolutions.net>
	<20160420144828.5537dce7@griffin>
	<1461158228.2176.18.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, nicolas.dichtel@6wind.com,
	egrumbach@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34341 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752966AbcDTNez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 09:34:55 -0400
In-Reply-To: <1461158228.2176.18.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Apr 2016 15:17:08 +0200, Johannes Berg wrote:
> Looks like you have this on a per-message basis. I thought it was
> better on an attribute basis because that's really where the issue is.

No problem. I'm not that happy with my patchset myself. Just wanted to
point it out in case it's useful.

 Jiri
