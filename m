From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qla3xxx: Ensure request/response queue addr writes to
 the registers
Date: Mon, 22 Oct 2012 15:17:24 -0400 (EDT)
Message-ID: <20121022.151724.1162375667344795177.davem@davemloft.net>
References: <50849604.9050109@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jitendra.kalsaria@qlogic.com, ron.mercer@qlogic.com,
	Linux-Driver@qlogic.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	greg.marsden@oracle.com
To: joe.jin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50849604.9050109@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Jin <joe.jin@oracle.com>
Date: Mon, 22 Oct 2012 08:40:36 +0800

> Before use the request and response queue addr, make sure it has wrote
> to the registers.
> 
> Signed-off-by: Joe Jin <joe.jin@oracle.com>

Applied.
