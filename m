From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] RxRPC: Fix kcalloc parameters swapped
Date: Tue, 14 Feb 2012 16:03:28 +0000
Message-ID: <18099.1329235408@redhat.com>
References: <1329200354.3806.1.camel@phoenix>
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Mimi Zohar <zohar@us.ibm.com>, Thomas Meyer <thomas@m3y3r.de>,
	Anton Blanchard <anton@samba.org>, netdev@vger.kernel.org
To: Axel Lin <axel.lin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329200354.3806.1.camel@phoenix>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Axel Lin <axel.lin@gmail.com> wrote:

> The first parameter should be "number of elements" and the second parameter
> should be "element size".
> 
> Signed-off-by: Axel Lin <axel.lin@gmail.com>

Not that it matters, I think, but let's be consistent...

Acked-by: David Howells <dhowells@redhat.com>
