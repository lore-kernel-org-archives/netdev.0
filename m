From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [git patch] urgent e1000 fix
Date: Thu, 23 Jun 2005 17:19:05 -0400
Message-ID: <42BB2749.1020209@pobox.com>
References: <42BA7FB5.5020804@pobox.com> <Pine.LNX.4.62.0506231402340.18154@qynat.qvtvafvgr.pbz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262709AbVFWVWG@vger.kernel.org>
To: David Lang <david.lang@digitalinsight.com>
In-Reply-To: <Pine.LNX.4.62.0506231402340.18154@qynat.qvtvafvgr.pbz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Lang wrote:
> hmm, I know I'm not that experianced with patch, but when I saved this 
> to a file and did patch -p1 <file the hunk was rejected, the reject file 
> is saying

It's probably the whitespace thing that Linus's git-apply gadget was 
complaining about.

I'm terribly surprising, though, since my patch(1) applied the diff just 
fine.

<shrug>

	Jeff
