From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: htb: fix a typo in htb_change_class()
Date: Wed, 11 Sep 2013 17:17:09 -0400 (EDT)
Message-ID: <20130911.171709.290821378041514980.davem@davemloft.net>
References: <1378859797.26319.90.camel@edumazet-glaptop>
	<20130911055827.GB1404@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, brouer@redhat.com,
	j.vimal@gmail.com, jpirko@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428Ab3IKVRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 17:17:12 -0400
In-Reply-To: <20130911055827.GB1404@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 11 Sep 2013 07:58:27 +0200

> Wed, Sep 11, 2013 at 02:36:37AM CEST, eric.dumazet@gmail.com wrote:
>>From: Vimalkumar <j.vimal@gmail.com>
>>
>>Fix a typo added in commit 56b765b79 ("htb: improved accuracy at high
>>rates")
>>
>>cbuffer should not be a copy of buffer.
>>
>>Signed-off-by: Vimalkumar <j.vimal@gmail.com>
>>Signed-off-by: Eric Dumazet <edumazet@google.com>
>>Cc: Jesper Dangaard Brouer <brouer@redhat.com>
>>Cc: Jiri Pirko <jpirko@redhat.com>
> Reviewed-by: Jiri Pirko <jiri@resnulli.us>

Applied and queued up for -stable, thanks everyone.
