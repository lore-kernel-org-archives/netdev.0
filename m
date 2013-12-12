From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: eth: davinci_cpdma: Mark a local variable
 static
Date: Wed, 11 Dec 2013 19:54:22 -0500 (EST)
Message-ID: <20131211.195422.656690100606056071.davem@davemloft.net>
References: <1386805882-25360-1-git-send-email-olof@lixom.net>
	<1386805882-25360-2-git-send-email-olof@lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org
To: olof@lixom.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386805882-25360-2-git-send-email-olof@lixom.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olof Johansson <olof@lixom.net>
Date: Wed, 11 Dec 2013 15:51:21 -0800

> Only used locally. Found by sparse.
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

Applied.
