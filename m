From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: r8821ae: Remove driver from staging
Date: Mon, 29 Sep 2014 02:17:44 -0400
Message-ID: <20140929061744.GA25093@kroah.com>
References: <1411954791-23779-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1411954791-23779-1-git-send-email-Larry.Finger@lwfinger.net>
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

On Sun, Sep 28, 2014 at 08:39:51PM -0500, Larry Finger wrote:
> A new version of this driver has been merged into the wireless-testing tree
> as commit 21e4b0726dc671c423e2dc9a85364716219c4502. It is both possible and
> desirable to delete the staging version to avoid build errors in linux-next.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
> 
> Greg,
> 
> This removal patch was generated after commit 368c75b98bdfdfad54e7f165016819ef344e3587.
> It should apply to your tree unless further modifications have been made to
> the staging driver.

Wonderful!

So, this should be done for 3.18-rc1, right?  Or does wireless-testing
take longer to get to Linus than that?

greg k-h
