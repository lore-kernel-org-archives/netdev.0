From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/4] Provide netdev naming-policy via sysfs
Date: Fri, 28 Mar 2014 21:42:54 -0400 (EDT)
Message-ID: <20140328.214254.1620280677250220442.davem@davemloft.net>
References: <CAG-2HqVJPrTWXtuvDkU6MvfNj0MXfNuBMmdoKWtSd5kToZ3mMQ@mail.gmail.com>
	<20140328.172107.16072208664321602.davem@davemloft.net>
	<CAG-2HqVQ-MAZgsZAkykvVtbtYgDA3bfJA5rEqpdX5vBqPTjLJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dh.herrmann@gmail.com, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: teg@jklm.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG-2HqVQ-MAZgsZAkykvVtbtYgDA3bfJA5rEqpdX5vBqPTjLJg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Gundersen <teg@jklm.no>
Date: Fri, 28 Mar 2014 23:39:57 +0100

> You mean coordinate with each other in userspace? If so, I still don't
> see how this can ever be anything else than fragile. It will depend on
> each userspace component actually opting in to whatever scheme we
> devise, and does so correctly.

Isn't that essentially what dbus is?

A way for seperate userland components to coordinate their
activities?

I just simply don't like all of these ramdom keys getting
added all over the place to guide udev behavior wrt. some
other entity.
