From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] tipc: sparse: fix htons conversion warnings
Date: Mon, 09 Mar 2015 15:39:23 -0400 (EDT)
Message-ID: <20150309.153923.1805666797592085162.davem@redhat.com>
References: <1425892771-15120-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, ying.xue@windriver.com,
	richard.alpe@ericsson.com, laszlo.benedek@ericsson.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60672 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753402AbbCITji (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 15:39:38 -0400
In-Reply-To: <1425892771-15120-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Mon, 9 Mar 2015 10:19:31 +0100

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> Commit d0f91938bede ("tipc: add ip/udp media type") introduced
> some new sparse warnings. Clean them up.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>

Applied.
