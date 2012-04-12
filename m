From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv6/exthdrs.c et al: Optional strict PadN option
 checking
Date: Thu, 12 Apr 2012 17:35:24 -0400 (EDT)
Message-ID: <20120412.173524.316812345318278932.davem@davemloft.net>
References: <1333811774-3219-1-git-send-email-eldad@fogrefinery.com>
	<20120412.160040.1086391259430365718.davem@davemloft.net>
	<CABe5r8JJPuhq3r=JnfLA=_U46-SFmK+g3XqC3MaRdLxwVXx9Qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eldad@fogrefinery.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABe5r8JJPuhq3r=JnfLA=_U46-SFmK+g3XqC3MaRdLxwVXx9Qw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eldad Zack <eldad@fogrefinery.com>
Date: Thu, 12 Apr 2012 23:31:47 +0200

> That's the way I see it, as was my initial intent. Then I got
> concerned with the possibility that a communication with
> slightly-broken stack implementation (e.g., unsanitized buffers) would
> fail without the user being able to control it at runtime.
> Do you consider this a non-issue?

I think it's a non-issue.
