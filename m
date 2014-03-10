From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] skbuff: skb_segment: s/fskb/list_skb/
Date: Mon, 10 Mar 2014 13:43:59 -0400 (EDT)
Message-ID: <20140310.134359.1940025401945824360.davem@davemloft.net>
References: <1394468807-25980-1-git-send-email-mst@redhat.com>
	<1394468807-25980-5-git-send-email-mst@redhat.com>
	<20140310.134054.2195508036199798660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jbenc@redhat.com,
	edumazet@google.com, dborkman@redhat.com, horms@verge.net.au,
	Paul.Durrant@citrix.com, tgraf@suug.ch,
	herbert@gondor.apana.org.au, mszeredi@suse.cz,
	panweiping3@gmail.com, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140310.134054.2195508036199798660.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Mon, 10 Mar 2014 13:40:54 -0400 (EDT)

> 
> As a netdev reader, I don't see patches 1-3, did you post them somewhere else
> and not CC: netdev?
> 
> If so, please don't do that without at least making a mention of what's going
> on in the 0/N posting.

Nevermind, I see them as older postings in my queue.

Are you using the commit date as the date for your outgoing emails?

Don't do that, it causes a patch series get chopped up and intertwined
with other ones in patchwork and therefore makes more work for me.
