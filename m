From: Grant Grundler <iod00d@hp.com>
Subject: Re: error compiling kernel...
Date: Mon, 7 Nov 2005 22:08:41 -0800
Message-ID: <20051108060841.GD18222@esmail.cup.hp.com>
References: <b9b9c93f0511041311s423c4ff6x531f211672d2ebcc@mail.gmail.com>
	<20051106105449.GR31134@mellanox.co.il>
	<4370275D.9060001@cse.ohio-state.edu>
	<20051108055949.GC18222@esmail.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20051108055949.GC18222@esmail.cup.hp.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 07, 2005 at 09:59:49PM -0800, Grant Grundler wrote:
> WARNING: /lib/modules/2.6.14/kernel/drivers/infiniband/ulp/sdp/ib_sdp.ko needs unknown symbol ip_dev_find                                                       
> Patch below adds EXPORT_SYMBOL() to fib_frontend.c.

...never mind. Johann George just pointed out someone already has
added this diff to the openib.org repository:
	https://openib.org/svn/gen2/trunk/src/linux-kernel/patches/linux-2.6.14-fib-frontend.diff

sorry,
grant
