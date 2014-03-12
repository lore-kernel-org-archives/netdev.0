From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/6] bluetooth: Convert uses of
 __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 15:28:34 -0400 (EDT)
Message-ID: <20140312.152834.46256646072434827.davem@davemloft.net>
References: <cover.1394643455.git.joe@perches.com>
	<51892631f2289665bf47b294c783ee9560a8317e.1394643455.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcel@holtmann.org, gustavo@padovan.org,
	johan.hedberg@gmail.com, linux-bluetooth@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51892631f2289665bf47b294c783ee9560a8317e.1394643455.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 12 Mar 2014 10:04:16 -0700

> The use of __constant_<foo> has been unnecessary for quite awhile now.
> 
> Make these uses consistent with the rest of the kernel.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Will let the bluetooth folks pick this one up.
