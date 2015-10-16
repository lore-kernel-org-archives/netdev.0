From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [RFC PATCH net-next 0/9] netlink: strict attribute checking
 option
Date: Fri, 16 Oct 2015 09:49:51 +0200
Message-ID: <20151016094951.11146959@griffin>
References: <cover.1444926905.git.jbenc@redhat.com>
	<87r3kv3hwv.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43160 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546AbbJPHty (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 03:49:54 -0400
In-Reply-To: <87r3kv3hwv.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Oct 2015 00:07:12 +0200, Hannes Frederic Sowa wrote:
> Do you plan to update rfc3549, too? :}

No.

While I think we need to have a detailed documentation on netlink,
I believe it should reside in Documentation/ inside the kernel tree to
be easily updated, not in an outside document collection with much more
heavyweight processes around getting something updated.

I would offer taking the RFC 3549 into the kernel tree and extending it
but my understanding of the license is that I'm not allowed to do that
(as I would modify the "document itself").

 Jiri

-- 
Jiri Benc
