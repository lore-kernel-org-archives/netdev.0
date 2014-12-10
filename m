From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 0/3] Faster than SLAB caching of SKBs with qmempool
 (backed by alf_queue)
Date: Wed, 10 Dec 2014 09:17:32 -0600 (CST)
Message-ID: <alpine.DEB.2.11.1412100917020.4047@gentwo.org>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20> <20141210141332.31779.56391.stgit@dragon>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
    linux-api@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20141210141332.31779.56391.stgit@dragon>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, 10 Dec 2014, Jesper Dangaard Brouer wrote:

>  Patch1: alf_queue (Lock-Free queue)

For some reason that key patch is not in my linux-mm archives nor in my
inbox.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
