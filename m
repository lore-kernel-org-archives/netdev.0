From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Documentation: networking: dmfe.txt: Remove the
 maintainer of orphan filesystem
Date: Thu, 15 Sep 2011 15:07:41 -0400 (EDT)
Message-ID: <20110915.150741.2213947519828728552.davem@davemloft.net>
References: <1314718437-5794-1-git-send-email-marcos.mage@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
To: marcos.mage@gmail.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1314718437-5794-1-git-send-email-marcos.mage@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcos Paulo de Souza <marcos.mage@gmail.com>
Date: Tue, 30 Aug 2011 12:33:57 -0300

> The dmfe module is a orphan driver, and with this was removed the maintainer
> of the documentation.
> 
> Signed-off-by: Marcos Paulo de Souza <marcos.mage@gmail.com>

Applied, but I changed "orphan filesystem" to "orphan networking driver"
since last time I checked dmfe is not a filesystem :)
