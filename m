From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 1/8] skb: report completion status for zero
	copy skbs
Date: Thu, 01 Nov 2012 12:20:00 -0400 (EDT)
Message-ID: <20121101.122000.264588573091276690.davem@davemloft.net>
References: <0dc176ed796ff5ac7164b6c18cc75d64c2a2317e.1351679008.git.mst@redhat.com>
	<20121101.115024.1422610516561380154.davem@davemloft.net>
	<20121101161611.GA9410@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, alexander.h.duyck@intel.com, Ian.Campbell@citrix.com,
	kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	akpm@linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121101161611.GA9410@redhat.com>
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
Date: Thu, 1 Nov 2012 18:16:11 +0200

> Do you think it's over-engineering, or a good idea?

Engineer what you need, not what you might need.
