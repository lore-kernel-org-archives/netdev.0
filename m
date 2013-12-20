From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/2] Fix problems with earlier patches
Date: Fri, 20 Dec 2013 13:11:34 -0800
Message-ID: <20131220211134.GA21301@kroah.com>
References: <1387573126-28907-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1387573126-28907-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 20, 2013 at 02:58:43PM -0600, Larry Finger wrote:
> A recent set of patches revealed that a line of code had been incorrectly
> removed in an earlier edit. That line is added back. In addition, a configuration
> problem resulted in a number of "unused variable" warnings.

Thanks for the quick fix, all now applied.

greg k-h
