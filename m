From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/32] Swap over NFS - v19
Date: Thu, 02 Oct 2008 15:05:04 +0200
Message-ID: <20081002130504.927878499@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fy
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754933AbYJBNTn@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patches are against: v2.6.27-rc5-mm1

This release features more comments and (hopefully) better Changelogs.
Also the netns stuff got sorted and ipv6 will now build and not oops
on boot ;-)

The first 4 patches are cleanups and can go in if the respective maintainers
agree.

The code is lightly tested but seems to work on my default config.

Let's get this ball rolling...
