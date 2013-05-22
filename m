From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 03/19] net/ethernet/atheros/atl1e/atl1e_main: Use module_pci_driver to register driver
Date: Wed, 22 May 2013 02:19:14 +0200
Message-ID: <20130522001914.GA9495@order.stressinduktion.org>
References: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de> <1369176146-19383-3-git-send-email-peterhuewe@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Joe Perches <joe@perches.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Patrick McHardy <kaber@trash.net>,
	"open list:ATLX ETHERNET DRI..." <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Peter Huewe <peterhuewe@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369176146-19383-3-git-send-email-peterhuewe@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 22, 2013 at 12:42:08AM +0200, Peter Huewe wrote:
> Removing some boilerplate by using module_pci_driver instead of calling
> register and unregister in the otherwise empty init/exit functions.
> 
> Signed-off-by: Peter Huewe <peterhuewe@gmx.de>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
