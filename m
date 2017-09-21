From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net:nfc: use setup_timer
Date: Thu, 21 Sep 2017 15:48:57 -0700 (PDT)
Message-ID: <20170921.154857.1879797632040993617.davem@davemloft.net>
References: <1505991573-30298-1-git-send-email-allen.lkml@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, sameo@linux.intel.com,
        netdev@vger.kernel.org
To: allen.lkml@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505991573-30298-1-git-send-email-allen.lkml@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allen Pais <allen.lkml@gmail.com>
Date: Thu, 21 Sep 2017 16:29:33 +0530

>     Use setup_timer function instead of initializing timer with the
>     function and data fields.
> 
> Signed-off-by: Allen Pais <allen.lkml@gmail.com>

Applied.
