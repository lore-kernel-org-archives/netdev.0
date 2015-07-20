From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: don't require ANY_LAYOUT with VERSION_1
Date: Mon, 20 Jul 2015 12:42:59 -0700 (PDT)
Message-ID: <20150720.124259.1513329118631759070.davem@davemloft.net>
References: <1436963135-16592-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtio-dev@lists.oasis-open.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1436963135-16592-1-git-send-email-mst@redhat.com>
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

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 15 Jul 2015 15:26:19 +0300

> ANY_LAYOUT is a compatibility feature. It's implied
> for VERSION_1 devices, and non-transitional devices
> might not offer it. Change code to behave accordingly.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied.
