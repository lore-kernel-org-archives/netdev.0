From: Lucas Meneghel Rodrigues <lmr@redhat.com>
Subject: Re: updated: kvm networking todo wiki
Date: Thu, 23 May 2013 11:12:52 -0300
Message-ID: <519E23E4.7020506@redhat.com>
References: <20130523085034.GA16142@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, vyasevic@redhat.com, "Xin,
	Xiaohui" <xiaohui.xin@intel.com>,
	Rusty Russell <rusty@rustcorp.com.au>, akong@redhat.com,
	kvm@vger.kernel.org, sriram.narasimhan@hp.com,
	netdev@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Shirley Ma <mashirle@us.ibm.com>,
	virtualization@lists.linux-foundation.org,
	David Stevens <dlstevens@us.ibm.com>, qemu-devel@nongnu.org,
	herbert@gondor.hengli.com.au,
	Anthony Liguori <anthony@codemonkey.ws>, jdike@linux.intel.com,
	sri@linux.vnet.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20130523085034.GA16142@redhat.com>
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

On 23/05/13 05:50 AM, Michael S. Tsirkin wrote:
> Hey guys,
> I've updated the kvm networking todo wiki with current projects.
> Will try to keep it up to date more often.
> Original announcement below.
>
> ----
>
> I've put up a wiki page with a kvm networking todo list,
> mainly to avoid effort duplication, but also in the hope
> to draw attention to what I think we should try addressing
> in KVM:
>
> http://www.linux-kvm.org/page/NetworkingTodo
>
> This page could cover all networking related activity in KVM,
> currently most info is related to virtio-net.
>
> Note: if there's no developer listed for an item,
> this just means I don't know of anyone actively working
> on an issue at the moment, not that no one intends to.
>
> I would appreciate it if others working on one of the items on this list
> would add their names so we can communicate better.  If others like this
> wiki page, please go ahead and add stuff you are working on if any.
>
> It would be especially nice to add autotest projects:
> there is just a short test matrix and a catch-all
> 'Cover test matrix with autotest', currently.

Ok, I'll take a look and fill in with currently available networking tests.

> Currently there are some links to Red Hat bugzilla entries,
> feel free to add links to other bugzillas.
>
> Thanks!
>
