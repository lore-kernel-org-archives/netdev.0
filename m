From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] Network namespace manipulation with file
 descriptors
Date: Mon, 09 May 2011 13:55:32 -0700 (PDT)
Message-ID: <20110509.135532.200362374.davem@davemloft.net>
References: <m1oc3btzk4.fsf@fess.ebiederm.org>
	<20110509.134007.116389415.davem@davemloft.net>
	<m1bozbtx0y.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	hadi@cyberus.ca, daniel.lezcano@free.fr, containers@lists.osdl.org,
	renatowestphal@gmail.com
To: ebiederm@xmission.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <m1bozbtx0y.fsf@fess.ebiederm.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 09 May 2011 13:54:37 -0700

> Do you know if there are any plans to support sendmmsg on parisc for
> 2.6.40?  That could get sticky as the parisc tree has a bunch of syscall
> catchup support they are doing now.

If you would like, you could send me a patch for net-next-2.6 that adds
the sendmmsg syscall entries and hooks for all the platforms not taken
care of right now.
