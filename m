From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/l2tp: fix build error in l2tp from
 missing ipv6 checksum include
Date: Mon, 30 Apr 2012 13:31:48 -0400 (EDT)
Message-ID: <20120430.133148.1694639055532709407.davem@davemloft.net>
References: <20120430155836.44bcf3846c80cf686bb9cb77@canb.auug.org.au>
	<20120430172402.GL17021@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: bcrl@kvack.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120430172402.GL17021@kvack.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Mon, 30 Apr 2012 13:24:02 -0400

> Can you please verify if the patch below fixes the issue?  Thanks.

I already checked a fix into the tree.
