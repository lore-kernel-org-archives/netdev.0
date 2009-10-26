From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC failures V2
Date: Tue, 27 Oct 2009 00:45:43 +0100
Message-ID: <200910270045.47456.elendil@planet.nl>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <200910262317.55960.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <jkosina@suse.cz>,
 Sven Geggus <lists@fuchsschwanzdomain.de>,
 Karol Lewandowski <karol.k.lewandowski@gmail.com>,
 Tobias Oetiker <tobi@oetiker.ch>,
 "Rafael J. Wysocki" <rjw@sisk.pl>,
 David Miller <davem@davemloft.net>,
 Reinette Chatre <reinette.chatre@intel.com>,
 Kalle Valo <kalle.valo@iki.fi>,
 David Rientjes <rientjes@google.com>,
 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
 Mohamed Abbas <mohamed.abbas@intel.com>,
 Jens Axboe <jens.axboe@oracle.com>,
 "John W. Linville" <linville@tuxdriver.com>,
 Pekka Enberg <penberg@cs.helsinki.fi>,
 Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
 Greg Kroah-Hartman <gregkh@suse.de>,
 Stephan von Krawczynski <skraw@ithnet.com>,
 Kernel Testers List <kernel-testers@vger.kernel.org>,
 netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 "linux-mm@kvack.org" <linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <200910262317.55960.elendil@planet.nl>
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Monday 26 October 2009, Frans Pop wrote:
> Detailed test results follow. I've done 2 test runs with each kernel (3
> for the last).

Forgot to mention that each run was after a reboot, so they are not 
interdependant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
