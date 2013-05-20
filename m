From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] x86: bpf_jit_comp: secure bpf jit against
 spraying attacks
Date: Sun, 19 May 2013 23:55:15 -0700 (PDT)
Message-ID: <20130519.235515.780417340578906662.davem@davemloft.net>
References: <1368844623.3301.142.camel@edumazet-glaptop>
	<519905B6.3080101@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, hpa@zytor.com,
	linux-kernel@vger.kernel.org
To: dborkman@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <519905B6.3080101@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sun, 19 May 2013 19:02:46 +0200

> Probably other archs could later on follow-up with setting to
> read-only, too.

Only s390 and x86 support this facility.
