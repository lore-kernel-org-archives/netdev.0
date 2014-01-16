From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH v2] ipv6: send Change Status Report after DAD is completed
Date: Thu, 16 Jan 2014 20:13:37 -0200
Message-ID: <20140116221337.GQ5359@plex.lan>
References: <1389907679-15346-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2254 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038AbaAPWMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 17:12:34 -0500
Content-Disposition: inline
In-Reply-To: <1389907679-15346-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is for net-next.
fbl

On Thu, Jan 16, 2014 at 07:27:59PM -0200, Flavio Leitner wrote:
> The RFC 3810 defines two type of messages for multicast
> listeners. The "Current State Report" message, as the name
> implies, refreshes the *current* state to the querier.
> Since the querier sends Query messages periodically, there
> is no need to retransmit the report.
[...] 
