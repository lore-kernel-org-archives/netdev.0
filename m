From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/3] net: mac80211: Neaten debugging
Date: Wed, 16 May 2012 08:22:51 -0700
Message-ID: <1337181771.4818.0.camel@joe2Laptop>
References: <1337106548.15553.8.camel@jlt3.sipsolutions.net>
	 <cover.1337116578.git.joe@perches.com>
	 <20120516.012319.1903390658912592000.davem@davemloft.net>
	 <1337155171.4367.2.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337155171.4367.2.camel@jlt3.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-16 at 09:59 +0200, Johannes Berg wrote:
> I wonder if it makes sense to leave these under
> #ifdef though? Why #ifdef something if it's going to be invisible most
> of the time anyway?

I don't understand your point.
#ifdef removal is a good thing.
