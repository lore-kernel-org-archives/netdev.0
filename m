From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] minor cleanup to net_namespace.c.
Date: Fri, 15 Apr 2011 15:48:06 -0700 (PDT)
Message-ID: <20110415.154806.245403763.davem@davemloft.net>
References: <4DA83971.7010903@parallels.com>
	<20110415123751.GC2697@psychotron>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rlandley@parallels.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: jpirko@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110415123751.GC2697@psychotron>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 15 Apr 2011 14:37:52 +0200

> Fri, Apr 15, 2011 at 02:26:25PM CEST, rlandley@parallels.com wrote:
>>From: Rob Landley <rlandley@parallels.com>
>>
>>Inline a small static function that's only ever called from one place.
>>
>>Signed-off-by: Rob Landley <rlandley@parallels.com>
 ...
> Reviewed-by: Jiri Pirko <jpirko@redhat.com>

Applied.
