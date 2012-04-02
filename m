From: Martin Lucina <martin@lucina.net>
Subject: Re: [PATCH] Implement IP_EVIL socket option (RFC 3514)
Date: Mon, 2 Apr 2012 11:42:49 +0200
Message-ID: <20120402094249.GB7601@dezo.moloch.sk>
References: <1333284791-5363-1-git-send-email-martin@lucina.net>
 <20120401.152048.267766557618433051.davem@davemloft.net>
 <20120402092410.GA7601@dezo.moloch.sk>
 <20120402.053544.1502825597915995582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120402.053544.1502825597915995582.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

davem@davemloft.net said:
> It wasn't the blurb it was simply that you're at least the third
> person to submit a patch like this over the years, here's one:
> 
> http://www.version6.net/patches/linux-2.4.20-rfc3514.dif
> 
> Someone did a netfilter iptables module too:
> 
> http://www.gossamer-threads.com/lists/linux/kernel/431645

I missed the former patch completely, sorry about that. Googling for "evil
bit implementation" did turn up the ipt_evil patch but no corresponding
patch to actually let an application *set* the bit.

-- 
Martin Lucina
http://lucina.net/ (interwebs/blogs/rants/consulting)
martin@lucina.net  (smtp/xmpp/jabber/gtalk)
@matolucina        (twitter)
