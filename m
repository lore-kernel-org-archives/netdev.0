From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Do not enable tx-nocache-copy by default
Date: Mon, 06 Jan 2014 20:00:02 -0500 (EST)
Message-ID: <20140106.200002.1747627391067832069.davem@davemloft.net>
References: <1389041855.12212.210.camel@edumazet-glaptop2.roam.corp.google.com>
	<1389050419-9060-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, therbert@google.com
To: bpoirier@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389050419-9060-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Poirier <bpoirier@suse.de>
Date: Mon,  6 Jan 2014 18:20:19 -0500

> There are many cases where this feature does not improve performance or even
> reduces it. See the following discussion for example perf numbers:
> http://thread.gmane.org/gmane.linux.network/298345
> 
> CC: Tom Herbert <therbert@google.com>
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>

Please don't provide data via a URL, which is transient.

Instead, include it inline in the commit message proper.

Thanks.
