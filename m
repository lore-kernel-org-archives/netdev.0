From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2 1/2] virtio-net: don't respond to cpu hotplug
	notifier if we're not ready
Date: Fri, 18 Oct 2013 03:13:17 -0400 (EDT)
Message-ID: <20131018.031317.1551678106943004158.davem@davemloft.net>
References: <87d2n3s89s.fsf@rustcorp.com.au>
	<20131017.234816.1960399038382112445.davem@davemloft.net>
	<87iowvje6t.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, gregkh@linuxfoundation.org
To: rusty@rustcorp.com.au
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87iowvje6t.fsf@rustcorp.com.au>
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

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 18 Oct 2013 16:47:14 +1030

> Do you want awk script to turn the latter into the former?  Would that
> really help?

Rusty in the several years I've been operating this way, you're
the first person who seems to mind it.

To be honest I sometimes just silently deal with the stable CC:,
but it's much easier if things operate as they do now, and the
burdon is on the submitter instead of me.
