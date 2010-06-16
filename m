From: David Miller <davem@davemloft.net>
Subject: Re: IMAP through SSH tunnels stopped working in 2.6.35
Date: Wed, 16 Jun 2010 12:04:39 -0700 (PDT)
Message-ID: <20100616.120439.104063332.davem@davemloft.net>
References: <1276683847.3874.25.camel@chi>
	<m3ocfbjle2.fsf@hase.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: plaes@plaes.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: schwab@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m3ocfbjle2.fsf@hase.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Schwab <schwab@redhat.com>
Date: Wed, 16 Jun 2010 12:56:53 +0200

> Priit Laes <plaes@plaes.org> writes:
> 
>> I recently tried out 2.6.35-rc3 kernel (latest Linus's tree), where I
>> noticed that I couldn't access my IMAP accounts through ssh tunnel
>> anymore because connection timeouts. Things used to work in 2.6.34-rc7+.
> 
> See <https://bugzilla.kernel.org/show_bug.cgi?id=16188>.

Also "linux-netdev" does not exist, it's just plain "netdev" :-)
