From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2 1/2] tuntap: do not zerocopy if iov needs more
 pages than MAX_SKB_FRAGS
Date: Tue, 30 Jul 2013 12:55:06 -0700 (PDT)
Message-ID: <20130730.125506.1487990387098277825.davem@davemloft.net>
References: <1374116116-43844-1-git-send-email-jasowang@redhat.com>
	<20130719050335.GA8537@redhat.com>
	<20130730114113.GA22218@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130730114113.GA22218@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 30 Jul 2013 14:41:13 +0300

> Was this patch dropped?

No, it's commit 885291761dba2bfe04df4c0f7bb75e4c920ab82e

> Any objections to merging it for 3.11 and stable?

No objections, queued up for -stable.
