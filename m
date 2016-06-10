From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] virtio_net: Update the feature bit to comply
	with spec
Date: Thu, 09 Jun 2016 23:35:37 -0700 (PDT)
Message-ID: <20160609.233537.1751385856841761894.davem@davemloft.net>
References: <1465494075-31170-1-git-send-email-aconole@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: aconole@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1465494075-31170-1-git-send-email-aconole@redhat.com>
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
Date: Thu,  9 Jun 2016 13:41:15 -0400

> A draft version of the MTU Advice feature bit was specified as 25.  This
> bit is not within the allowed range for network device feature bits, and
> should be changed to be feature bit 3 to fully comply with the spec.
> 
> Fixes 14de9d114a82 ('virtio-net: Add initial MTU advice feature')
> Signed-off-by: Aaron Conole <aconole@redhat.com>
> Suggested-by: "Michael S. Tsirkin" <mst@redhat.com>

Applied.
