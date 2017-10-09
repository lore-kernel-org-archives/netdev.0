From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qed: Delete redundant check on dcb_app priority
Date: Sun, 08 Oct 2017 21:21:18 -0700 (PDT)
Message-ID: <20171008.212118.949521469342318166.davem@davemloft.net>
References: <1507502807-19767-1-git-send-email-chris.gekas@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ariel.Elior@cavium.com, everest-linux-l2@cavium.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: chris.gekas@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507502807-19767-1-git-send-email-chris.gekas@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christos Gkekas <chris.gekas@gmail.com>
Date: Sun,  8 Oct 2017 23:46:47 +0100

> dcb_app priority is unsigned thus checking whether it is less than zero
> is redundant.
> 
> Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>

Applied to net-next.
