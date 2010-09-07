From: Christoph Hellwig <hch@infradead.org>
Subject: Re: RFC: Crypto API User-interface
Date: Tue, 7 Sep 2010 10:55:12 -0400
Message-ID: <20100907145512.GB13027@infradead.org>
References: <834983542.1086561283871074929.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
 <695962299.1087031283871123333.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Miloslav Trmac <mitr@redhat.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <695962299.1087031283871123333.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 07, 2010 at 10:52:03AM -0400, Miloslav Trmac wrote:
> Because in the real world people want both certification, features _and_ performance.  If all they cared about is certification they could just as well buy a pencil.

Okay Mr Smartass.  Please put away your crackpipe and get down to earth.
There is absolutely no good reason to ever do crypto for userspace
applications in the kernel.  If any certification requires that it's not
worth the paper it's written on.  In fact there's more enough criticial
systems that do not even have separate kernel vs userspace boundaries.
