From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v2 1/2] hisilicon net: removes the once HANDEL_TX_MSG macro
Date: Mon, 12 Oct 2015 13:53:42 +0200
Message-ID: <7677925.qV8yFrBeTx@wuerfel>
References: <1444620225-2339-1-git-send-email-huangdaode@hisilicon.com> <1444620278.8012.41.camel@perches.com> <561B2B30.1020400@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Joe Perches <joe@perches.com>, davem@davemloft.net,
	liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
	netdev@vger.kernel.org, linuxarm@huawei.com,
	salil.mehta@huawei.com, kenneth-lee-2012@foxmail.com,
	xuwei5@hisilicon.com, lisheng011@huawei.com,
	linux-kernel@vger.kernel.org
To: huangdaode <huangdaode@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <561B2B30.1020400@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 12 October 2015 11:38:24 huangdaode wrote:
> On 2015/10/12 11:24, Joe Perches wrote:
> > Hello Huang.
> >
> > On Mon, 2015-10-12 at 11:23 +0800, huangdaode wrote:
> >> This patch changes the code style to make the code more simple.
> >> also removes the once used HNADEL_TX_MSG macro, according to the
> > HANDEL_TX_MSG typo
> >
> >> review comments from Joe Perches.
> >>
> >> Signed-off-by: huangdaode <huangdaode@hisilicon.com>
> >> Reviewed-by: Joe Perches <joe@perches.com>
> > I didn't review this.
> > '
> Hi Joe
> please refer to http://lists.openwall.net/netdev/2015/10/11/61

You should only add the "Reviewed-by" tag to a commit message
if the person you are adding replied with this explicitly.
Don't add it just because someone gave feedback.

	Arnd
