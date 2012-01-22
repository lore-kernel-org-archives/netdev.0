From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/2] virtio: fix typos of memory barriers
Date: Mon, 23 Jan 2012 09:37:08 +1030
Message-ID: <871uqrgwv7.fsf@rustcorp.com.au>
References: <20120120081658.50747.10625.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120122114746.GC27222@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120122114746.GC27222@redhat.com>
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

On Sun, 22 Jan 2012 13:47:46 +0200, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> On Fri, Jan 20, 2012 at 04:16:59PM +0800, Jason Wang wrote:
> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> Good catch.
> Note: this fixes a bug introduced by
> 7b21e34fd1c272e3a8c3846168f2f6287a4cd72b.
> It's probably a good idea to mention
> this is the commit log.
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Thanks, applied!

Cheers,
Rusty.
