From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATH] IPv6 IPsec support
Date: Wed, 05 Mar 2003 07:21:49 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030305.072149.121185037.davem@redhat.com>
References: <20030305233025.784feb00.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kazunori@miyazawa.org
In-Reply-To: <20030305233025.784feb00.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Kazunori Miyazawa <kazunori@miyazawa.org>
   Date: Wed, 5 Mar 2003 23:30:25 +0900

Hello Miyazawa-san,

   I submit the patch to let the kernel support ipv6 ipsec again.
   It is able to comple ipv6 as module.
   
   This patch incldes a couple of clean-up and
   changes of function name.

Excellent work.

I have comments, but they are very minor and can wait.
I will apply your patch after basic build testing.

The next large task will be to abstract out more common
pieces of code.  There is still quite a bit of code duplication
between v4 and v6 xfrm methods,

Thank you!
