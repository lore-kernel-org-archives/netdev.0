From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: tap devices not receiving packets from a bridge
Date: Tue, 12 Feb 2013 11:54:23 +0200
Message-ID: <20130212095422.GA23270@redhat.com>
References: <50AE36E0.8000307@dlhnet.de>
	<20121123070211.GC22787@stefanha-thinkpad.hitronhub.home>
	<E85C6011-548D-4507-A776-1028DD3E3515@dlhnet.de>
	<20121123110146.GC7051@redhat.com> <50FE5607.9020405@dlhnet.de>
	<20130123100312.GA8108@redhat.com> <5119E9DC.3000505@dlhnet.de>
	<20130212090850.GB22029@redhat.com>
	<056542E4-18E4-4C9F-AC96-60661768D6AF@dlhnet.de>
	<511A0DBB.7080907@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Hajnoczi <stefanha@gmail.com>, Peter Lieven <pl@dlhnet.de>,
	qemu-devel@nongnu.org, netdev@vger.kernel.org
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
Content-Disposition: inline
In-Reply-To: <511A0DBB.7080907@msgid.tls.msk.ru>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 12, 2013 at 01:39:07PM +0400, Michael Tokarev wrote:
> 12.02.2013 13:10, Peter Lieven wrote:
> []
> 
> Guys, can we please trim the excessive quoting just a bit? ;)
> 
> >>> If have set this option for 2 weeks now and not seen this problem again.
> >>> How does this flag work with the recently added tap multiqueue support?
> 
> >>This will be the only option in 3.8.
> 
> >Ok, but wouldn`t it be good to set it in qemu for kernels <3.8?
> 
> I'd say for kernels without mq support, not for <3.8, right? :)
> 
> Thanks,
> 
> /mjt

It's harmless to always set this flag, on 3.8 it does nothing.

-- 
MST
