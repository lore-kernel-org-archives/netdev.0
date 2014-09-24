From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [PATCH v2] et131x: Promote staging et131x driver to drivers/net
Date: Wed, 24 Sep 2014 10:00:05 +0100
Message-ID: <20140924090004.GA5097@leicester.auvation.com>
References: <1411421283-25073-1-git-send-email-mark.einon@gmail.com>
 <1411502723-4628-1-git-send-email-mark.einon@gmail.com>
 <1411506437.29268.13.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, angus@agibson.me, gregkh@linuxfoundation.org,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1411506437.29268.13.camel@joe-AO725>
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

On Tue, Sep 23, 2014 at 02:07:17PM -0700, Joe Perches wrote:
> On Tue, 2014-09-23 at 21:05 +0100, Mark Einon wrote:
> > This patch moves the et131x gigabit ethernet driver from drivers/staging
> > to drivers/net/ethernet/agere.
> 
> checkpatch type modification you might consider:
> 
> Reduce logging line count by consolidating repeated dev_warn
> Use ether_addr_copy
> Line wrapping for 80 columns
> Remove unnecessary parentheses
> Remove unnecessary OOM message

Considered and done, thanks.

Mark
