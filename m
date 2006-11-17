From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 8/10] cxgb3 - offload capabilities
Date: Fri, 17 Nov 2006 12:51:59 -0800
Message-ID: <20061117125159.530b46c7@freekitty>
References: <20061117202539.25951.95325.stgit@colfax2.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:46273 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1753168AbWKQUyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 15:54:05 -0500
To: "Divy Le Ray <divy@chelsio.com>" <divy@chelsio.com>
In-Reply-To: <20061117202539.25951.95325.stgit@colfax2.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Nov 2006 12:25:39 -0800
"Divy Le Ray <divy@chelsio.com>" <divy@chelsio.com> wrote:

> From: Divy Le Ray <divy@chelsio.com>
> 
> This patch implements the offload capabilities of the
> Chelsio network adapter's driver.

Could you implement these as sysfs attributes on the device instead of
through /proc?
