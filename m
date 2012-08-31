From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: fix shutdown parameter checking
Date: Fri, 31 Aug 2012 15:57:30 -0400 (EDT)
Message-ID: <20120831.155730.665786534434857698.davem@davemloft.net>
References: <1346035633-2492-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xi.wang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346035633-2492-1-git-send-email-xi.wang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xi Wang <xi.wang@gmail.com>
Date: Sun, 26 Aug 2012 22:47:13 -0400

> Return -EINVAL rather than 0 given an invalid "mode" parameter.
> 
> Signed-off-by: Xi Wang <xi.wang@gmail.com>

Applied to net-next
