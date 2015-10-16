From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [RFC PATCH net-next 0/9] netlink: strict attribute checking
 option
Date: Fri, 16 Oct 2015 12:00:09 +0200
Message-ID: <20151016120009.45459a75@griffin>
References: <cover.1444926905.git.jbenc@redhat.com>
	<87r3kv3hwv.fsf@stressinduktion.org>
	<20151016094951.11146959@griffin>
	<20151016.010826.1557577128395519123.davem@davemloft.net>
	<20151016100843.44c9172a@griffin>
	<1444988411.2852230.411870761.15F9E4C9@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	tgraf@suug.ch
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44834 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752787AbbJPKAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 06:00:13 -0400
In-Reply-To: <1444988411.2852230.411870761.15F9E4C9@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Oct 2015 11:40:11 +0200, Hannes Frederic Sowa wrote:
> I would suggest you simply add a description to the rfc via the errata
> process here: <https://www.rfc-editor.org/errata_report.php>
> 
> The original cover letter should be enough to post there. I am also not
> sure if people do really implement this spec, at least they have a
> pointer to it, then. AFAIK the IESG will look into that then and even
> non-approved erratas will be listed on the rfc page.

Okay, we may do that. But let's postpone this discussion after we
decide what route we'll go. We'll definitely need some form of
documentation but it's preliminary to discuss what exact form when we
haven't decided whether we'll implement something like this at all.

 Jiri

-- 
Jiri Benc
