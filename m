From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next 2014-08-01
Date: Sat, 02 Aug 2014 19:39:39 -0700 (PDT)
Message-ID: <20140802.193939.2179004210212543536.davem@davemloft.net>
References: <20140801165738.GA26953@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140801165738.GA26953@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 1 Aug 2014 12:57:38 -0400

> Please pull this last(?) batch of wireless change intended for the
> 3.17 stream...

When I pull this I get tons of conflicts for:

CONFLICT (content): Merge conflict in net/6lowpan/iphc.c

I don't feel comfortable fixing these up, where are they coming
from?
