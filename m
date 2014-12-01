From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH v7 29/46] vhost: add memory access wrappers
Date: Mon, 1 Dec 2014 13:13:31 +0100
Message-ID: <20141201131331.226d964a.cornelia.huck@de.ibm.com>
References: <1417359787-10138-1-git-send-email-mst@redhat.com>
	<1417359787-10138-30-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, kvm@vger.kernel.org, rusty@au1.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	dahi@linux.vnet.ibm.com, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1417359787-10138-30-git-send-email-mst@redhat.com>
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

On Sun, 30 Nov 2014 17:11:39 +0200
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> Add guest memory access wrappers to handle virtio endianness
> conversions.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Reviewed-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/vhost/vhost.h | 31 +++++++++++++++++++++++++++++++
>  1 file changed, 31 insertions(+)
> 
Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
