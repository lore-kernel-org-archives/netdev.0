From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] virtio-net: Add initial MTU advice feature
Date: Mon, 06 Jun 2016 21:10:59 -0400 (EDT)
Message-ID: <20160606.211059.447701408091916319.davem@davemloft.net>
References: <1464987432-1458-1-git-send-email-aconole@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: aconole@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1464987432-1458-1-git-send-email-aconole@redhat.com>
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

From: Aaron Conole <aconole@redhat.com>
Date: Fri,  3 Jun 2016 16:57:12 -0400

> This commit adds the feature bit and associated mtu device entry for the
> virtio network device.  When a virtio device comes up, it checks the
> feature bit for the VIRTIO_NET_F_MTU feature.  If such feature bit is
> enabled, the driver will read the advised MTU and use it as the initial
> value.
> 
> Signed-off-by: Aaron Conole <aconole@redhat.com>

Applied, thanks.
