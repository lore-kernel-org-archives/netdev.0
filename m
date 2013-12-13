From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3] ipv6: log autoconfiguration failures
Date: Fri, 13 Dec 2013 17:57:09 -0500 (EST)
Message-ID: <20131213.175709.414078764436451428.davem@davemloft.net>
References: <1386949547-23457-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jpirko@redhat.com
To: dvlasenk@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386949547-23457-1-git-send-email-dvlasenk@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Fri, 13 Dec 2013 16:45:47 +0100

> If ipv6 auto-configuration does not work, currently it's hard
> to track what's going on. This change adds log messages
> (at debug level) on every code path where ipv6 autoconf fails.
> 
> v3: changed pr_debug's to pr_warn's.
> 
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>

I already made it clear I want to see statistics added instead of log
messages for this.

I'm not applying this patch, sorry.
