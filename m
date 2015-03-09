From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: macb: constify macb configuration data
Date: Mon, 09 Mar 2015 15:54:19 -0400 (EDT)
Message-ID: <20150309.155419.1761757350216222476.davem@redhat.com>
References: <1425917679-11956-1-git-send-email-joshc@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joshc@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425917679-11956-1-git-send-email-joshc@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josh Cartwright <joshc@ni.com>
Date: Mon, 9 Mar 2015 11:14:39 -0500

> The configurations are not modified by the driver.  Make them 'const' so
> that they may be placed in a read-only section.
> 
> Signed-off-by: Josh Cartwright <joshc@ni.com>

Applied.
