From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [RFC PATCH net-next 0/9] netlink: strict attribute checking
 option
Date: Fri, 16 Oct 2015 10:08:43 +0200
Message-ID: <20151016100843.44c9172a@griffin>
References: <cover.1444926905.git.jbenc@redhat.com>
	<87r3kv3hwv.fsf@stressinduktion.org>
	<20151016094951.11146959@griffin>
	<20151016.010826.1557577128395519123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34211 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752762AbbJPIIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 04:08:47 -0400
In-Reply-To: <20151016.010826.1557577128395519123.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Oct 2015 01:08:26 -0700 (PDT), David Miller wrote:
> I think his point is that you'll be making changes to an RFC specified
> protocol.

The RFC is only informational, it has never became an Internet
standard (under the RFC terms). And no other OS picked it up. Keeping
kernel uAPI documentation in IETF database sounds rather inefficient.

> But I think we need a better solution to this.

I'm not opposed to a better solution. I just don't see any that's not
a gross hack. Suggestions are welcome.

 Jiri

-- 
Jiri Benc
