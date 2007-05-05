From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [patch 25/29] xen: Add the Xen virtual network device driver.
Date: Sat, 05 May 2007 20:16:50 +1000
Message-ID: <1178360210.12284.130.camel@localhost.localdomain>
References: <20070504232051.411946839@goop.org>
	<20070504232121.492190579@goop.org>
	<20070505091624.GA8890@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Jeff Garzik <jeff@garzik.org>,
        Ian Pratt <ian.pratt@xensource.com>, netdev@vger.kernel.org,
        lkml <linux-kernel@vger.kernel.org>,
        Chris Wright <chrisw@sous-sol.org>, virtualization@lists.osdl.org,
        Stephen Hemminger <shemminge@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20070505091624.GA8890@infradead.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-05-05 at 10:16 +0100, Christoph Hellwig wrote:
> I wish people would have listened to me back then and made the
> description part of the modular_param statement..

Sometimes we weary of change.  However, come up with a decent name and
implement it and we can deprecate module_param() by say... 2012?

Cheers,
Rusty.
