From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] vhost: remove unnecessary smp_mb from
 vhost_work_queue
Date: Thu, 08 Dec 2016 11:30:46 -0500 (EST)
Message-ID: <20161208.113046.64351554585995048.davem@davemloft.net>
References: <1481104340-77035-1-git-send-email-bergwolf@gmail.com>
        <1481104340-77035-2-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefanha@redhat.com, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: bergwolf@gmail.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1481104340-77035-2-git-send-email-bergwolf@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peng Tao <bergwolf@gmail.com>
Date: Wed,  7 Dec 2016 17:52:19 +0800

> test_and_set_bit() already implies a memory barrier.
> 
> Signed-off-by: Peng Tao <bergwolf@gmail.com>

Applied.
