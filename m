From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] ibmveth fix panic in initial replenish cycle
Date: Fri, 4 Nov 2005 17:23:37 -0500
Message-ID: <20051104222329.GB31524@tuxdriver.com>
References: <20051101175617.25145.73324.sendpatchset@ltcml8p7.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751072AbVKDWZg@vger.kernel.org>
To: Santiago Leon <santil@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20051101175617.25145.73324.sendpatchset@ltcml8p7.rchland.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 01, 2005 at 02:15:09PM -0500, Santiago Leon wrote:
> This patch fixes a panic in the current tree caused by a race condition between the initial replenish cycle and the rx processing of the first packets trying to replenish the buffers.

Please restrain your line widths to less than 80 characters.  72 is
a nice number IMHO.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
