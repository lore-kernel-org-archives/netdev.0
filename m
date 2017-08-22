From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ax88796: make mdiobb_ops const
Date: Tue, 22 Aug 2017 14:21:27 -0700 (PDT)
Message-ID: <20170822.142127.1556796890290919849.davem@davemloft.net>
References: <1503389479-17429-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503389479-17429-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Tue, 22 Aug 2017 13:41:19 +0530

> Make this const as it is only stored in a const field of a
> mdiobb_ctrl structure.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied.
