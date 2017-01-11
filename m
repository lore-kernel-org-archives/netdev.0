From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: thunderx: Fix error return code in
 nicvf_open()
Date: Wed, 11 Jan 2017 16:12:51 -0500 (EST)
Message-ID: <20170111.161251.1979714688980792559.davem@davemloft.net>
References: <20170111163251.19367-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: weiyongjun1@huawei.com, sgoutham@cavium.com, rric@kernel.org,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170111163251.19367-1-weiyj.lk@gmail.com>
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

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 11 Jan 2017 16:32:51 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix to return a negative error code from the error handling
> case instead of 0, as done elsewhere in this function.
> 
> Fixes: 712c31853440 ("net: thunderx: Program LMAC credits based on MTU")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
