From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio-net: Remove more stack DMA
Date: Tue, 12 Jul 2016 10:40:30 -0700 (PDT)
Message-ID: <20160712.104030.1596691470300748311.davem@davemloft.net>
References: <1ff8c3e69b8d4f1ad717affa073b279a74ee4309.1468272497.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org
To: luto@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1ff8c3e69b8d4f1ad717affa073b279a74ee4309.1468272497.git.luto@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 11 Jul 2016 14:30:28 -0700

> DaveM, is it okay for this to go in via -tip?

Sure.
