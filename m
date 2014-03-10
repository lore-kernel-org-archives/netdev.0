From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 4/5] skbuff: skb_segment: s/fskb/list_skb/
Date: Mon, 10 Mar 2014 19:56:06 +0200
Message-ID: <20140310175606.GA13907@redhat.com>
References: <1394468807-25980-1-git-send-email-mst@redhat.com>
 <1394468807-25980-5-git-send-email-mst@redhat.com>
 <20140310.134054.2195508036199798660.davem@davemloft.net>
 <20140310.134359.1940025401945824360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jbenc@redhat.com,
	edumazet@google.com, dborkman@redhat.com, horms@verge.net.au,
	Paul.Durrant@citrix.com, tgraf@suug.ch,
	herbert@gondor.apana.org.au, mszeredi@suse.cz,
	panweiping3@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140310.134359.1940025401945824360.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 10, 2014 at 01:43:59PM -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 10 Mar 2014 13:40:54 -0400 (EDT)
> 
> > 
> > As a netdev reader, I don't see patches 1-3, did you post them somewhere else
> > and not CC: netdev?
> > 
> > If so, please don't do that without at least making a mention of what's going
> > on in the 0/N posting.
> 
> Nevermind, I see them as older postings in my queue.
> 
> Are you using the commit date as the date for your outgoing emails?

I don't really know, I just used git send-email to prepare them.

I saw a large delay after I sent them all until patches 4/5
appeared on list. Could just be some hiccup in the smtp server
(using ssmtp).

> Don't do that, it causes a patch series get chopped up and intertwined
> with other ones in patchwork and therefore makes more work for me.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
