From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/9] several fixups for virtio-net XDP
Date: Fri, 23 Dec 2016 13:49:11 -0500 (EST)
Message-ID: <20161223.134911.389678142108691826.davem@davemloft.net>
References: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
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

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 23 Dec 2016 22:37:23 +0800

> Merry Xmas and a Happy New year to all:
> 
> This series tries to fixes several issues for virtio-net XDP which
> could be categorized into several parts:
> 
> - fix several issues during XDP linearizing
> - allow csumed packet to work for XDP_PASS
> - make EWMA rxbuf size estimation works for XDP
> - forbid XDP when GUEST_UFO is support
> - remove big packet XDP support
> - add XDP support or small buffer
> 
> Please see individual patches for details.

Series applied, thanks Jason.
