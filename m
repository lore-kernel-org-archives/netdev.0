From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
	failures V2
Date: Tue, 27 Oct 2009 13:27:04 +0000
Message-ID: <20091027132704.GE8900@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <20091024140207.GA5102@geggus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>,
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
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754814AbZJ0N1F@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091024140207.GA5102@geggus.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 24, 2009 at 04:02:09PM +0200, Sven Geggus wrote:
> Mel Gorman schrieb am Donnerstag, den 22. Oktober um 16:22 Uhr:
> 
> > Test 1: Verify your problem occurs on 2.6.32-rc5 if you can
> 
> Problem persists. RAID resync in progress :(
> 

What about the rest of the patches, any luck?

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
