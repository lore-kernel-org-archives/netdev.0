From: Mark Einon <mark@einon.net>
Subject: Re: [PATCH] et131x: Promote staging et131x driver to drivers/net
Date: Tue, 30 Sep 2014 20:45:10 +0100
Message-ID: <20140930194510.GC1982@msilap.einon.net>
References: <1412104572-2931-1-git-send-email-mark.einon@gmail.com>
 <20140930193201.GA2349@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Mark Einon <mark.einon@gmail.com>,
 netdev@vger.kernel.org, davem@davemloft.net, linux-kernel@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20140930193201.GA2349@kroah.com>
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

On Tue, Sep 30, 2014 at 12:32:01PM -0700, Greg KH wrote:
> 
> This is a fine way to make a patch, but it's no way that any of the
> netdev developers could ever review it to know what the code happens to
> look like in my staging-next branch :(
> 
> How about just sending a patch that adds the driver to drivers/net/...
> Don't worry about the staging driver at the moment.  If it gets added to
> drivers/net we can then delete the staging driver.
> 
> Sound easier?  Should make the patches half as big.

Sounds resonable, will do.

Cheers,

Mark
