From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: add dev_loopback_xmit() to avoid duplicate
 code
Date: Wed, 23 May 2012 13:41:34 -0400 (EDT)
Message-ID: <20120523.134134.1083024931902332575.davem@davemloft.net>
References: <1337782819.2779.20.camel@Thor>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, edumazet@google.com, jpirko@redhat.com,
	mirq-linux@rere.qmqm.pl, bhutchings@solarflare.com
To: michel@digirati.com.br
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337782819.2779.20.camel@Thor>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'm getting really tired of saying this.

As I announced several days ago, it is absolutely not appropriate
to submit patches other than bug fixes at this time because we are
in the merge window and the net-next tree is frozen.

And even once I do announce here that the net-next tree is open
once more, and patches like this one are appropriate, you must
indicate in the subject line which of the 'net' or 'net-next'
tree you are targetting your patch at.

Please pay attention to what's going on, and what state the networking
development trees are in, before submitting changes.
