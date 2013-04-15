From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/macb: fix error return code in macb_probe()
Date: Mon, 15 Apr 2013 14:10:20 -0400 (EDT)
Message-ID: <20130415.141020.1721813812373854975.davem@davemloft.net>
References: <1366013073-22934-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yongjun_wei@trendmicro.com.cn,
 plagnioj@jcrosoft.com, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: nicolas.ferre@atmel.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1366013073-22934-1-git-send-email-nicolas.ferre@atmel.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Mon, 15 Apr 2013 10:04:33 +0200

> Fix to return a negative error code from the error handling
> case instead of 0, as returned elsewhere in this function.
> 
> Original-idea-by: <yongjun_wei@trendmicro.com.cn>
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Applied.
