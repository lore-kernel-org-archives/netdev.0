From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next RFC V2 PATCH 0/5] Multiqueue support in
	tun/tap
Date: Sat, 17 Sep 2011 22:17:09 +0300
Message-ID: <20110917191709.GA6127@redhat.com>
References: <20110917055639.32666.89940.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, eric.dumazet@gmail.com,
	qemu-devel@nongnu.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, joe@perches.com,
	shemminger@vyatta.com, mirq-linux@rere.qmqm.pl, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
Content-Disposition: inline
In-Reply-To: <20110917055639.32666.89940.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: </archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 17, 2011 at 02:02:04PM +0800, Jason Wang wrote:
> A wiki-page was created to narrate the detail design of all parts
> involved in the multi queue implementation:
> http://www.linux-kvm.org/page/Multiqueue and some basic tests result
> could be seen in this page
> http://www.linux-kvm.org/page/Multiqueue-performance-Sep-13. I would
> post the detail numbers in attachment as the reply of this thread.

Does it make sense to test both with and without RPS in guest?

-- 
MST
