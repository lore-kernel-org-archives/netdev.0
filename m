From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 3/8] macvtap: introduce macvtap_is_little_endian()
	helper
Date: Mon, 01 Jun 2015 16:38:14 -0700 (PDT)
Message-ID: <20150601.163814.2119052442730023727.davem@davemloft.net>
References: <20150424122211.19156.97626.stgit@bahia.local>
	<20150424122446.19156.93123.stgit@bahia.local>
	<20150601122950-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thuth@redhat.com, kvm@vger.kernel.org, linux-api@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20150601122950-mutt-send-email-mst@redhat.com>
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
Date: Mon, 1 Jun 2015 12:30:16 +0200

> On Fri, Apr 24, 2015 at 02:24:48PM +0200, Greg Kurz wrote:
>> Signed-off-by: Greg Kurz <gkurz@linux.vnet.ibm.com>
> 
> Dave, could you pls ack merging this through the virtio tree?

Acked-by: David S. Miller <davem@davemloft.net>
