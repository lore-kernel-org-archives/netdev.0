From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5] r8169: auto detect 32-bit slot
Date: Wed, 09 Mar 2005 14:47:57 -0500
Message-ID: <422F52ED.2060606@pobox.com>
References: <20050309112925.7f7900ab@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050309112925.7f7900ab@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Change driver to auto-detect when the board is in a 32-bit PCI slot and
> avoid setting 64-bit dma mask. The module parameter method is no longer needed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

need to set consistent DMA mask too
