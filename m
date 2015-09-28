From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 6/7] slub: optimize bulk slowpath free by detached
 freelist
Date: Mon, 28 Sep 2015 10:22:50 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1509281017300.30332@east.gentwo.org>
References: <20150928122444.15409.10498.stgit@canyon> <20150928122634.15409.6956.stgit@canyon>
Content-Type: text/plain; charset=US-ASCII
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-ch2-03v.sys.comcast.net ([69.252.207.35]:37126 "EHLO
	resqmta-ch2-03v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933905AbbI1PWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 11:22:51 -0400
In-Reply-To: <20150928122634.15409.6956.stgit@canyon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Acked-by: Christoph Lameter <cl@linux.com>
