From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ewrk3: range checking problem
Date: Mon, 22 Mar 2010 18:33:31 -0700 (PDT)
Message-ID: <20100322.183331.45148439.davem@davemloft.net>
References: <20100322120728.GD21571@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, kaber@trash.net,
	jpirko@redhat.com, adobriyan@gmail.com,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100322120728.GD21571@bicker>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <error27@gmail.com>
Date: Mon, 22 Mar 2010 15:07:28 +0300

> The range checking here is wrong.  It should be HASH_TABLE_LEN which 
> is 512.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
