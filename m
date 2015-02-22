From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] __aligned(size) is preferred over
 __attribute__((aligned(size)))
Date: Sun, 22 Feb 2015 17:02:38 -0500 (EST)
Message-ID: <20150222.170238.779470624458267514.davem@davemloft.net>
References: <1424641236-7671-1-git-send-email-ameenali023@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ameenali023@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424641236-7671-1-git-send-email-ameenali023@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cFrom: Ameen Ali <ameenali023@gmail.com>
Date: Sun, 22 Feb 2015 23:40:36 +0200

> Signed-off-by: Ameen Ali <AmeenAli023@gmail.com>

Applied, but please use a proper Subject line next time,
in particular you should put a proper subsystem prefix.

In this case, "net: " would be an appropriate prefix.

Otherwise people scanning the shortlog in the repository
cannot tell where you are making your changes.

What if we had 100 commits all doing this same transformation?
It is the subsystem prefix that helps people see what is unique
in each such change.
