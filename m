From: David Miller <davem@davemloft.net>
Subject: Re: Shared i2c adapter locking
Date: Tue, 17 Nov 2009 03:51:47 -0800 (PST)
Message-ID: <20091117.035147.80164577.davem@davemloft.net>
References: <20091105150715.692b5200@hyperion.delvare>
	<20091117193313.b750804e.sfr@canb.auug.org.au>
	<20091117103554.03971b2f@hyperion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, mika.kuoppala@nokia.com,
	linux-i2c@vger.kernel.org
To: khali@linux-fr.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755923AbZKQLvc@vger.kernel.org>
In-Reply-To: <20091117103554.03971b2f@hyperion.delvare>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jean Delvare <khali@linux-fr.org>
Date: Tue, 17 Nov 2009 10:35:54 +0100

> If you did and something is still not clear, please let me know. My
> understanding is that the action token is in David's hands now.

So what exactly do I need to do?

All I see that needs to happen is to pull from Linus's tree into
net-2.6

But frankly I don't see how that helps resolve anything in linux-next
since Stephen starts with Linus's tree then pulls in everyone's work.

Or is that pull necessary so that some other patch can be applied
to net-2.6 or similar?
