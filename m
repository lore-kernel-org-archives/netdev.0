From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 0/3] Slab allocator array operations
Date: Fri, 6 Feb 2015 12:39:28 -0600 (CST)
Message-ID: <alpine.DEB.2.11.1502061239050.17507@gentwo.org>
References: <20150123213727.142554068@linux.com> <20150123145734.aa3c6c6e7432bc3534f2c4cc@linux-foundation.org> <alpine.DEB.2.11.1501231827330.10083@gentwo.org> <20150204001922.5650ca4b@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
    linux-mm@kvack.org, penberg@kernel.org,
    "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150204001922.5650ca4b@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Feb 2015, Jesper Dangaard Brouer wrote:

> I promised Christoph that I will performance benchmark this. I'll start
> by writing/performing some micro benchmarks, but it first starts to get
> really interesting once we plug it into e.g. the networking stack, as
> effects as instruction-cache misses due to code size starts to play a
> role.

Ok I got a patchset here with the options removed. Just the basic ops.
Should I repost that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
