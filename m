From: "Jaswinder Singh Rajput" <jaswinderlinux@gmail.com>
Subject: Re: [GIT]: Networking
Date: Tue, 6 Jan 2009 10:44:11 +0530
Message-ID: <3f9a31f40901052114t68cac881md439bf24b602f269@mail.gmail.com>
References: <alpine.LFD.2.00.0901051839330.3057@localhost.localdomain>
	 <20090105.201530.195720489.davem@davemloft.net>
	 <alpine.LFD.2.00.0901052029220.3057@localhost.localdomain>
	 <20090105.204934.65827705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"David Woodhouse" <dwmw2@infradead.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:62424 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbZAFFOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 00:14:12 -0500
In-Reply-To: <20090105.204934.65827705.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2009 at 10:19 AM, David Miller <davem@davemloft.net> wrote:
>
> I had 4 firmware patches to apply, each one had to add entries
> to the same file.
>
> The first patch had to be skipped.
>

In firmware we maintain WHENCE, so every time we add new firmware we
also update WHENCE.

We are facing problems while we prepare patch for firmware as we add
new stuff at the end.
As per David Woodhouse suggestion, I arranged WHENCE to alphabetical
order by driver name to avoid conflicts.

I also send patch on 21 Dec 2008 with ack of David Woodhouse to linus
and waiting from his side.

[PATCH] firmware: Arrange WHENCE in alphabetical order to avoid conflicts

I think this will resolve very soon, once we update WHENCE in
alphabetical order, If you better suggestions, please let me know.

Thanks,
--
JSR
