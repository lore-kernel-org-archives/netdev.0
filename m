From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 0/6] vhost code cleanup and minor enhancement
Date: Tue, 03 Sep 2013 22:47:41 -0400 (EDT)
Message-ID: <20130903.224741.300532243318088831.davem@davemloft.net>
References: <1378111261-14826-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1378111261-14826-1-git-send-email-jasowang@redhat.com>
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
Date: Mon,  2 Sep 2013 16:40:55 +0800

> This series tries to unify and simplify vhost codes especially for
> zerocopy. With this series, 5% - 10% improvement for per cpu throughput were
> seen during netperf guest sending test.
> 
> Plase review.

Applied and patch #5 queued up for -stable, thanks.
