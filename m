From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Tue, 09 Jul 2013 21:35:55 -0700 (PDT)
Message-ID: <20130709.213555.1037822981842851807.davem@davemloft.net>
References: <20130709.145325.1363244885668360965.davem@davemloft.net>
	<CA+55aFwgYoGKRLde_4KBnUr1nENpwdahJv8+wHJ502HcGJW1pA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFwgYoGKRLde_4KBnUr1nENpwdahJv8+wHJ502HcGJW1pA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 9 Jul 2013 19:50:41 -0700

> Now, I'm all for making descriptive merge commit messages, including
> improving on the summary line. So by all means write those nice merge
> messages with explanations. I think something like
> 
>     dc3d807d6fd9 Merge "openvswitch: gre tunneling support."
> 
> would have been a *fine* summary line, for example, and quite possibly
> better than the default kind of git merge summary lines (ie "Merge
> branch 'openswitch'"). So I'm not against playing with merge messages
> per se, it's literally this "cannot tell it's a merge any more in the
> summary" that I thing is a problem.

Ok, I'll use that format in the future.  I was actually trying to add
more information, not less. :-) But yeah that header line has to
mention that it's a merge, for sure.
