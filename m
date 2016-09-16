From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net/ibm/emac: add mutex to 'set multicast list'
Date: Fri, 16 Sep 2016 04:22:14 -0400 (EDT)
Message-ID: <20160916.042214.1138945942496120956.davem@davemloft.net>
References: <1473869205-85314-2-git-send-email-ivan@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ivan@de.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473869205-85314-2-git-send-email-ivan@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Mikhaylov <ivan@de.ibm.com>
Date: Wed, 14 Sep 2016 19:06:45 +0300

> for preventing race conditions within ioctl calls.
> 
> Signed-off-by: Ivan Mikhaylov <ivan@de.ibm.com>

Applied.
