From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
 failures V2
Date: Fri, 23 Oct 2009 21:52:39 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0910232151380.2001@V090114053VZO-1>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <84144f020910220747nba30d8bkc83c2569da79bd7c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Mel Gorman <mel@csn.ul.ie>, Frans Pop <elendil@planet.nl>,
    Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>,
    Karol Lewandowski <karol.k.lewandowski@gmail.com>,
    Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>,
    David Miller <davem@davemloft.net>,
    Reinette Chatre <reinette.chatre@intel.com>,
    Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>,
    KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
    Mohamed Abbas <mohamed.abbas@intel.com>,
    Jens Axboe <jens.axboe@oracle.com>,
    "John W. Linville" <linville@tuxdriver.com>,
    Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
    Greg Kroah-Hartman <gregkh@suse.de>,
    Stephan von Krawczynski <skraw@ithnet.com>,
    Kernel Testers List <kernel-testers@vger.kernel.org>,
    netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
    "li
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <84144f020910220747nba30d8bkc83c2569da79bd7c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Oct 2009, Pekka Enberg wrote:

> These are pretty obvious bug fixes and should go to linux-next ASAP IMHO.

Bug fixes go into main not linux-next. Lets make sure these fixes really
work and then merge.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
