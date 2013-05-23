From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: updated: kvm networking todo wiki
Date: Thu, 23 May 2013 11:50:34 +0300
Message-ID: <20130523085034.GA16142@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, qemu-devel@nongnu.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: David Stevens <dlstevens@us.ibm.com>, sri@linux.vnet.ibm.com,
	Anthony Liguori <anthony@codemonkey.ws>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, Shirley Ma <mashirle@us.ibm.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>, jdike@linux.intel.com,
	herbert@gondor.hengli.com.au, lmr@redhat.com, akong@redhat.com,
	Jason Wang <jasowang@redhat.com>, vyasevic@redhat.com,
	sriram.narasimhan@hp.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hey guys,
I've updated the kvm networking todo wiki with current projects.
Will try to keep it up to date more often.
Original announcement below.

----

I've put up a wiki page with a kvm networking todo list,
mainly to avoid effort duplication, but also in the hope
to draw attention to what I think we should try addressing
in KVM:

http://www.linux-kvm.org/page/NetworkingTodo

This page could cover all networking related activity in KVM,
currently most info is related to virtio-net.

Note: if there's no developer listed for an item,
this just means I don't know of anyone actively working
on an issue at the moment, not that no one intends to.

I would appreciate it if others working on one of the items on this list
would add their names so we can communicate better.  If others like this
wiki page, please go ahead and add stuff you are working on if any.

It would be especially nice to add autotest projects:
there is just a short test matrix and a catch-all
'Cover test matrix with autotest', currently.

Currently there are some links to Red Hat bugzilla entries,
feel free to add links to other bugzillas.

Thanks!

-- 
MST
