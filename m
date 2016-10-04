From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: hns: mark symbols static where possible
Date: Mon, 03 Oct 2016 21:52:00 -0400 (EDT)
Message-ID: <20161003.215200.2029190598743365433.davem@davemloft.net>
References: <1475309726-21334-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        yankejian@huawei.com, huangdaode@hisilicon.com,
        lisheng011@huawei.com, xieqianqian@huawei.com, fabf@skynet.be,
        lipeng321@huawei.com, colin.king@canonical.com,
        simon.horman@netronome.com, arnd@arndb.de, andrew@lunn.ch,
        ivecera@redhat.com, chenny.xu@huawei.com, xypron.glpk@gmx.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        xie.baoyou@zte.com.cn, han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475309726-21334-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Sat,  1 Oct 2016 16:15:26 +0800

> We get a few warnings when building kernel with W=1:
 ...
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> So this patch marks these functions with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Still doesn't apply to net-next.
