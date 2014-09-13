From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/3] virtio_net: pass well-formed sgs to virtqueue_add_*()
Date: Sat, 13 Sep 2014 15:10:03 +0930
Message-ID: <87ioksgjt8.fsf@rustcorp.com.au>
References: <1410396458-1165-1-git-send-email-rusty@rustcorp.com.au> <1410396458-1165-2-git-send-email-rusty@rustcorp.com.au> <20140912.175440.1013837932148725302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mst@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140912.175440.1013837932148725302.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> Do you guys want me to take this series directly into net-next?

Actually, yes.  Since I'm going to be travelling, that makes it much
easier for me.  And no other patches I have depend on it.

Thanks!
Rusty.
