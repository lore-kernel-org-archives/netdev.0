From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: staging: r8822be: Add code for halmac sub-driver
Date: Tue, 29 Aug 2017 13:26:43 +0200
Message-ID: <20170829112643.GA14571@kroah.com>
References: <20170817174652.17656-5-Larry.Finger@lwfinger.net>
 <0758af1e-f8d5-97be-8308-ba5535ab9415@fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Yan-Hsuan Chuang <yhchuang@realtek.com>,
 Birming Chiu <birming@realtek.com>, netdev <netdev@vger.kernel.org>,
 Steven Ting <steventing@realtek.com>, Larry Finger <Larry.Finger@lwfinger.net>
To: Andreas Ziegler <andreas.ziegler@fau.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <0758af1e-f8d5-97be-8308-ba5535ab9415@fau.de>
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

On Tue, Aug 29, 2017 at 12:59:27PM +0200, Andreas Ziegler wrote:
> Hi Ping-Ke, hi Larry,
> 
> I noticed your commit in linux-next today using the in-tree script at
> scripts/checkkconfigsymbols.py [0]. The script showed that it uses
> CONFIG_RTL_DEBUG in an #ifdef statement - this symbol, however, does not exist,
> and should probably be CONFIG_RTLWIFI_DEBUG instead.
> 
> I attached a patch which fixes this problem.

Please resend this in a format in which I can apply it in (i.e. in a
proper email, cc: the correct mailing lists, etc.)

thanks,

greg k-h
