From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] VSOCK: revert virtio-vsock until device spec is
 finalized
Date: Tue, 08 Dec 2015 11:26:55 -0500 (EST)
Message-ID: <20151208.112655.353902854757115664.davem@davemloft.net>
References: <1449575856-28507-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mbenjamin@redhat.com, kvm@vger.kernel.org,
	christoffer.dall@linaro.org, mst@redhat.com,
	virtualization@lists.linux-foundation.org, matt.ma@linaro.org
To: stefanha@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1449575856-28507-1-git-send-email-stefanha@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Tue,  8 Dec 2015 19:57:30 +0800

> Please revert for now.

Please don't revert it piece by piece like this.

Instead, send me one big revert commit that undoes the whole
thing.  There is even a merge commit that you can use to
create that revert cleanly.

Thanks.
