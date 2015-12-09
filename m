From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: Initialize local variables to NULL, to
 prevent using them when uninitialized.
Date: Wed, 9 Dec 2015 14:50:55 +0100
Message-ID: <20151209135055.GA1280@salvia>
References: <1449310123-31503-1-git-send-email-barletz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tomer Barletz <barletz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1449310123-31503-1-git-send-email-barletz@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We already have this:

http://git.kernel.org/cgit/linux/kernel/git/pablo/nf.git/commit/?id=8e662164abb4a8fde701a46e1431980f9e325742

We'll be sending this today to David to avoid this annoyance.

Thanks for you patch anyway.
