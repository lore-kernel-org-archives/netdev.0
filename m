From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net/at91_ether: fix the use of macb structure
Date: Mon, 5 Nov 2012 00:02:35 +0100
Message-ID: <5096F40B.60509@atmel.com>
References: <75eb5df193c504e68ebff7d6a6a88d9a1cc678cb.1351591858.git.nicolas.ferre@atmel.com>
 <1351596628-3405-1-git-send-email-nicolas.ferre@atmel.com>
 <20121103.150414.707741347606909244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, manabian@gmail.com, patrice.vilchez@atmel.com,
 linux-kernel@vger.kernel.org, havard@skinnemoen.net, bhutchings@solarflare.com,
 plagnioj@jcrosoft.com, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20121103.150414.707741347606909244.davem@davemloft.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 11/03/2012 08:04 PM, David Miller :
> From: Nicolas Ferre <nicolas.ferre@atmel.com>
> Date: Tue, 30 Oct 2012 12:30:28 +0100
> 
>> Due to the use of common structure in at91_ether and macb drivers,
>> change the name of DMA descriptor structures in at91_ether as well:
>> dma_desc => macb_dma_desc
>>
>> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> 
> This does not apply to net-next, respin it if this change is
> still relevant.

This one is not relevant anymore.

Best regards,
-- 
Nicolas Ferre
