From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 2.6.12-rc2 3/10] tg3: add bcm5752 entry to pci_ids.h
Date: Thu, 21 Apr 2005 16:59:56 -0700
Message-ID: <20050421165956.55bdcb14.davem@davemloft.net>
References: <04132005193844.8410@laptop>
	<04132005193844.8474@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <04132005193844.8474@laptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 13 Apr 2005 19:38:44 -0400
"John W. Linville" <linville@tuxdriver.com> wrote:

> Add proper entry for bcm5752 PCI ID to pci_ids.h, and use it in tg3.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> I did this separately in case patches like this (i.e. new PCI IDs)
> need to come from more "official" sources.

Applied, thanks.  Don't we need a drivers/pci/pci.ids update as
well?
