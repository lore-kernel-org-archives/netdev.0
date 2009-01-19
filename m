From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: 64k bind(0) bugfix.
Date: Tue, 20 Jan 2009 02:26:56 +0300
Message-ID: <20090119232656.GA13963@ioremap.net>
References: <20090119232151.GA13659@ioremap.net> <20090119.152432.32346720.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.net.ru ([195.178.208.66]:59462 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752127AbZASX0w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 18:26:52 -0500
Content-Disposition: inline
In-Reply-To: <20090119.152432.32346720.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2009 at 03:24:32PM -0800, David Miller (davem@davemloft.net) wrote:
> If I end up rebasing the net-next tree before publishing, I'll
> integrate this fix into the original commit.

Great, thank you!

-- 
	Evgeniy Polyakov
