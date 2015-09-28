From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/7] slub: mark the dangling ifdef #else of
 CONFIG_SLUB_DEBUG
Date: Mon, 28 Sep 2015 08:49:15 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1509280849020.23642@east.gentwo.org>
References: <20150928122444.15409.10498.stgit@canyon> <20150928122619.15409.68763.stgit@canyon>
Content-Type: text/plain; charset=US-ASCII
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
    netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>,
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150928122619.15409.68763.stgit@canyon>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Sep 2015, Jesper Dangaard Brouer wrote:

> The #ifdef of CONFIG_SLUB_DEBUG is located very far from
> the associated #else.  For readability mark it with a comment.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
