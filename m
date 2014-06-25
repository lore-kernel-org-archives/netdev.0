From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] crc32 combine improvements
Date: Wed, 25 Jun 2014 16:04:33 -0700 (PDT)
Message-ID: <20140625.160433.1012876682294424845.davem@davemloft.net>
References: <1403529116-18385-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@horizon.com,
	linux-kernel@vger.kernel.org
To: dborkman@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403529116-18385-1-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 23 Jun 2014 15:11:53 +0200

> So almost a month passed, and I don't want this to get lost
> somewhere. I have applied the feedback given at that time to
> this set, rebased plus tested it against latest net-next. I
> decided to route this via netdev as it improves performance
> upon library code that provides library bits for SCTP, i.e.
> for non-linear skb csum handling in IPVS. Thus, resending
> this for George before it gets lost.

Series applied, thanks Daniel.
