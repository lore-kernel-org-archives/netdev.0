From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH net V2] virtio-net: alloc big buffers also when guest can
	receive UFO
Date: Mon, 24 Feb 2014 12:00:51 +1030
Message-ID: <87vbw570vo.fsf@rustcorp.com.au>
References: <1392959284-11399-1-git-send-email-jasowang@redhat.com>
	<20140221145550.GA4408@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, Sridhar Samudrala <sri@us.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140221145550.GA4408@redhat.com>
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

"Michael S. Tsirkin" <mst@redhat.com> writes:
> On Fri, Feb 21, 2014 at 01:08:04PM +0800, Jason Wang wrote:
>> We should alloc big buffers also when guest can receive UFO
>> pakcets to let the big packets be fit into guest rx buffer.
>
> s/pakcets/packets/
>
> s/be fit/fit/
>
> otherwise:
>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Indeed.

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks,
Rusty.
