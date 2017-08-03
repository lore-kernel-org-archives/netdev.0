From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] qlcnic: add const to bin_attribute structure
Date: Thu, 03 Aug 2017 09:29:08 -0700 (PDT)
Message-ID: <20170803.092908.1155197228589181228.davem@davemloft.net>
References: <1501696634-15765-1-git-send-email-bhumirks@gmail.com>
        <1501696634-15765-3-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, kvalo@codeaurora.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, harish.patil@cavium.com,
        manish.chopra@cavium.com, Dept-GELinuxNICDev@cavium.com
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501696634-15765-3-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Wed,  2 Aug 2017 23:27:14 +0530

> Add const to bin_attribute structure as it is only passed to the
> functions sysfs_{remove/create}_bin_file. The corresponding
> arguments are of type const, so declare the structure to be const.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied.
