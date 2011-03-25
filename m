From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix fib metrics
Date: Thu, 24 Mar 2011 17:22:48 -0700 (PDT)
Message-ID: <20110324.172248.124014531.davem@davemloft.net>
References: <20110324.153623.45921344.davem@davemloft.net>
	<1301006652.2714.145.camel@edumazet-laptop>
	<AANLkTi=Xb3KCBKoVCcaVD5iyCtMCAnYaGF_DTeFQ0ays@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: alessandro.suardi@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=Xb3KCBKoVCcaVD5iyCtMCAnYaGF_DTeFQ0ays@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alessandro Suardi <alessandro.suardi@gmail.com>
Date: Fri, 25 Mar 2011 01:12:11 +0100

> If some change in the kernel broke my userspace, this usually
>  qualifies as a regression.

Not if userspace was working on an assumption it was not allowed to
make, which we believe it is in this case.
