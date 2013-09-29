From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] fib_trie: avoid a redundant bit judgement
 in inflate
Date: Sun, 29 Sep 2013 17:31:06 -0400 (EDT)
Message-ID: <20130929.173106.475537080284868036.davem@davemloft.net>
References: <1380461518-10095-1-git-send-email-baker.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: baker.kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380461518-10095-1-git-send-email-baker.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Based upon how quickly you sent these two patches, the first of which
wouldn't even compile, I have zero confidence that you actually
booted and tested this patch at all.

I'm not applying this until you take the time to boot and test the
change in some way, and say explicitly in your commit message how
you tested it.
