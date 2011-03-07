From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [rds-devel] [PATCH] rds: prevent BUG_ON triggering on congestion map updates
Date: Mon, 07 Mar 2011 15:41:04 -0500
Message-ID: <1299530363-sup-8922@think>
References: <1299083302-5168-1-git-send-email-nhorman@tuxdriver.com> <20110307.122753.59686845.davem@davemloft.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: nhorman <nhorman@tuxdriver.com>, netdev <netdev@vger.kernel.org>,
	rds-devel <rds-devel@oss.oracle.com>,
	"Venkat Venkatsubra" <venkat.x.venkatsubra@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:18777 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658Ab1CGUnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 15:43:02 -0500
In-reply-to: <20110307.122753.59686845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Excerpts from David Miller's message of 2011-03-07 15:27:53 -0500:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed,  2 Mar 2011 11:28:22 -0500
> 
> > Recently had this bug halt reported to me:
> 
> Well, does anyone on the RDS team care about this bug fix at all?
> 
> Stuff like this should not sit for nearly a week without any reply
> whatsoever.
> 

The patch looks good to me, but I'm surprised we haven't seen it here.
Venkat please take a look (link to the patch below)  Has it only been seen on ppc?

http://permalink.gmane.org/gmane.linux.network/187933

-chris
