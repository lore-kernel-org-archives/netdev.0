From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/6] 8021q: Convert uses of __constant_<foo>
 to <foo>
Date: Wed, 12 Mar 2014 15:28:20 -0400 (EDT)
Message-ID: <20140312.152820.462492181681872969.davem@davemloft.net>
References: <cover.1394643455.git.joe@perches.com>
	<c44725e4804d6e64f44263bfcb4d4c3d2d057db4.1394643455.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c44725e4804d6e64f44263bfcb4d4c3d2d057db4.1394643455.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 12 Mar 2014 10:04:15 -0700

> The use of __constant_<foo> has been unnecessary for quite awhile now.
> 
> Make these uses consistent with the rest of the kernel.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
