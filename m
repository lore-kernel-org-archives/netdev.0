From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/4] Provide netdev naming-policy via sysfs
Date: Sat, 29 Mar 2014 15:37:37 -0400 (EDT)
Message-ID: <20140329.153737.671362434625537776.davem@davemloft.net>
References: <CAG-2HqVQ-MAZgsZAkykvVtbtYgDA3bfJA5rEqpdX5vBqPTjLJg@mail.gmail.com>
	<20140328.214254.1620280677250220442.davem@davemloft.net>
	<CAG-2HqWQsLPaaHxMFn5Bha0BGKSAVZV9n87KTCsbQ1ewktzZvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dh.herrmann@gmail.com, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: teg@jklm.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG-2HqWQsLPaaHxMFn5Bha0BGKSAVZV9n87KTCsbQ1ewktzZvA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Gundersen <teg@jklm.no>
Date: Sat, 29 Mar 2014 10:46:02 +0100

> The issue I see with that is that there are several ways to generate
> predictable names, and the user may want to chose between them, so
> this is arguably policy that should not be in the kernel. If you don't
> think that's a problem, I'd be happy to submit a patch to move all
> this logic from udev to the kernel, just let me know how you see it.

Unfortunately, we have already allowed this kind of thing for setting
MAC addresses so I guess I'll have to allow your changes to be applied.

But before I ask you to resubmit, do you have full buy-in from the
udev folks for this facility?

Thanks.
