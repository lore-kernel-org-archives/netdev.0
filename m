From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: ipv6_create_tempaddr cleanup
Date: Tue, 03 Sep 2013 22:17:10 -0400 (EDT)
Message-ID: <20130903.221710.1608165855708248750.davem@davemloft.net>
References: <1377874958-2426-1-git-send-email-pholasek@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: pholasek@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377874958-2426-1-git-send-email-pholasek@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Petr Holasek <pholasek@redhat.com>
Date: Fri, 30 Aug 2013 17:02:38 +0200

> This two-liner removes max_addresses variable which is now unecessary related
> to patch [ipv6: remove max_addresses check from ipv6_create_tempaddr].
> 
> Signed-off-by: Petr Holasek <pholasek@redhat.com>

Applied, thanks.
