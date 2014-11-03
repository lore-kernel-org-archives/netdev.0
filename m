From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hamradio: 6pack: remove unnecessary check
Date: Mon, 03 Nov 2014 15:34:53 -0500 (EST)
Message-ID: <20141103.153453.1235728189727221805.davem@davemloft.net>
References: <1415016749-6825-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ajk@comnets.uni-bremen.de, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sudipm.mukherjee@gmail.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1415016749-6825-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Mon,  3 Nov 2014 17:42:29 +0530

> this is check for dev is unnecessary, as we are already checking dev
> after allocating it via alloc_netdev, and jumping to label: out
> if it is NULL.
> 
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>

Applied, thanks.
