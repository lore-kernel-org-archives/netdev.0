From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv3] virtio-spec: virtio network device multiqueue support
Date: Fri, 7 Sep 2012 02:16:47 +0300
Message-ID: <20120906231647.GB1873@redhat.com>
References: <20120906120828.GA1534@redhat.com>
 <5048D2B8.4060003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Paolo Bonzini <pbonzini@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <5048D2B8.4060003@redhat.com>
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

On Thu, Sep 06, 2012 at 06:43:36PM +0200, Paolo Bonzini wrote:
> Il 06/09/2012 14:08, Michael S. Tsirkin ha scritto:
> > +#define VIRTIO_NET_CTRL_STEERING_HOST  1
> 
> You didn't change this occurrence.

Good catch, thanks!
