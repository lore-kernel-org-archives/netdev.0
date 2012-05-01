From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/16] Swap-over-NBD without deadlocking V9
Date: Tue, 1 May 2012 15:28:26 -0700
Message-ID: <20120501152826.b970a098.akpm@linux-foundation.org>
References: <1334578624-23257-1-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
 Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike
 Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1334578624-23257-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


This patchset is far less ghastly than I feared/remembered/dreamed ;)

The mm parts, anyway.  Are the net guys on board with it all?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
