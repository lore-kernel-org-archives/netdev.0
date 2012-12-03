From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Sun, 2 Dec 2012 16:13:30 -0800
Message-ID: <CA+55aFy1sa=D-DrWqNuvjrLW8J0Tw1+GbZhXv6VHTTTxXG_DMA@mail.gmail.com>
References: <20121128.214732.1634269294133625782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121128.214732.1634269294133625782.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David, Willy pointed me to the recent splice crash fix
(do_tcp_sendpages and non-0-order pages). It's apparently easily
user-triggerable.. Should I take the patch directly, or do you have a
tree to pull. Don't want to make a release with a known oopser..

          Linus
