From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] virtio_net: use common code for virtio_net_hdr and
	skb GSO conversion
Date: Fri, 10 Jun 2016 23:04:18 -0700 (PDT)
Message-ID: <20160610.230418.775808325943254175.davem@davemloft.net>
References: <1465391362-18437-1-git-send-email-rppt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: rppt@linux.vnet.ibm.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1465391362-18437-1-git-send-email-rppt@linux.vnet.ibm.com>
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

From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Wed,  8 Jun 2016 16:09:16 +0300

> This patches introduce virtio_net_hdr_{from,to}_skb functions for
> conversion of GSO information between skb and virtio_net_hdr.

Looks like a nice cleanup to me, series applied, thanks Mike.
