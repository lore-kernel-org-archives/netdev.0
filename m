From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: ipv6_create_tempaddr cleanup
Date: Sun, 1 Sep 2013 20:35:33 +0200
Message-ID: <20130901183533.GB19455@order.stressinduktion.org>
References: <1377874958-2426-1-git-send-email-pholasek@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Petr Holasek <pholasek@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1377874958-2426-1-git-send-email-pholasek@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 30, 2013 at 05:02:38PM +0200, Petr Holasek wrote:
> This two-liner removes max_addresses variable which is now unecessary related
> to patch [ipv6: remove max_addresses check from ipv6_create_tempaddr].
> 
> Signed-off-by: Petr Holasek <pholasek@redhat.com>

Uh, yes, I missed that. Thanks a lot!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
