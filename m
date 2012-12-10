From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv7] virtio-spec: virtio network device multiqueue support
Date: Tue, 11 Dec 2012 10:20:09 +1030
Message-ID: <87sj7dcvri.fsf@rustcorp.com.au>
References: <20121210104025.GA26640@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121210104025.GA26640@redhat.com>
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

> Add multiqueue support to virtio network device.
> Add a new feature flag VIRTIO_NET_F_MQ for this feature, a new
> configuration field max_virtqueue_pairs to detect supported number of
> virtqueues as well as a new command VIRTIO_NET_CTRL_MQ to program
> packet steering for unidirectional protocols.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Thanks, applied.

Cheers,
Rusty.
