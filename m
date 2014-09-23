From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [RFC PATCH linux-next] et131x: Promote staging et131x driver to
 drivers/net
Date: Tue, 23 Sep 2014 10:50:04 +0100
Message-ID: <20140923095004.GB5130@leicester.auvation.com>
References: <1411421283-25073-1-git-send-email-mark.einon@gmail.com>
 <1411437445.2952.61.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 netdev@vger.kernel.org, davem@davemloft.net, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1411437445.2952.61.camel@joe-AO725>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Mon, Sep 22, 2014 at 06:57:25PM -0700, Joe Perches wrote:
> On Mon, 2014-09-22 at 22:28 +0100, Mark Einon wrote:
> > This patch moves the et131x gigabit ethernet driver from drivers/staging
> > to drivers/net/ethernet/agere.
> > 
> > There are no known issues at this time.
> 
> This doesn't apply to -next or -linux

Hi Joe,

Thanks for the review.

Yes, there are a further (minor) 8 patches by me on the driver-devel
list that are needed that this patch is based upon, as per my comment
below. As the merge window is close, I've put this out an an RFC to
get feedback ASAP.

> 
> []
> > This patch will only apply once the last few pending changes
> > make their way from staging-next to linux-next, but posting
> > now in the hope that feedback can be given and this change can
> > make it in before the next merge window.n yo
> 
> When you do post the actual patch, can you please use
> "git format-patch -M" so that the patch is significantly
> smaller and the renames are obvious?

Will do, thanks.

Mark
