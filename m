From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH ] more RTL-8139 clone boards
Date: Wed, 19 Nov 2003 09:27:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031119092751.3407c944.shemminger@osdl.org>
References: <3FBA771A.1010104@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Xose Vazquez Perez <xose@wanadoo.es>
In-Reply-To: <3FBA771A.1010104@wanadoo.es>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 18 Nov 2003 20:46:34 +0100
Xose Vazquez Perez <xose@wanadoo.es> wrote:

> 
> 0x018A 0x0106 LevelOne FPC-0106TX
> 0x126C 0x1211 Nortel Networks 10/100BaseTX
> 0x1743 0x8139 Peppercon AG ROL-F
> 0x021B 0x8139 Compaq HNE-300

Maybe time to  start using pci_ids.h?
