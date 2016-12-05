From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mm PATCH 0/3] Page fragment updates
Date: Mon, 5 Dec 2016 12:11:31 -0800
Message-ID: <20161205121131.3c1d9ad8452d5e09247336e4@linux-foundation.org>
References: <20161129182010.13445.31256.stgit@localhost.localdomain>
	<CAKgT0UchMkvsboO23R332j96=yumL7=oSSm97zqJ5-v30_SgCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm <linux-mm@kvack.org>, Netdev <netdev@vger.kernel.org>, Eric
 Dumazet <edumazet@google.com>, David Miller <davem@davemloft.net>, Jeff
 Kirsher <jeffrey.t.kirsher@intel.com>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CAKgT0UchMkvsboO23R332j96=yumL7=oSSm97zqJ5-v30_SgCw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Dec 2016 09:01:12 -0800 Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On Tue, Nov 29, 2016 at 10:23 AM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
> > This patch series takes care of a few cleanups for the page fragments API.
> >
> > ...
> 
> It's been about a week since I submitted this series.  Just wanted to
> check in and see if anyone had any feedback or if this is good to be
> accepted for 4.10-rc1 with the rest of the set?

Looks good to me.  I have it all queued for post-4.9 processing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
