From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Wake up km_waitq after changing policies
Date: Mon, 30 Aug 2004 14:36:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830143656.2b8ec69f.davem@redhat.com>
References: <20040830152728.GA19086@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
        kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20040830152728.GA19086@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


kaber@trash.net will eventually work on this, it involves
adding support for unresolved destination cache entries.
It's a lot of complex work, so don't expect it any time soon.
