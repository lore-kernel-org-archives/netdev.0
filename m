From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/6] staging: r8188eu: Replace wrapper around _rtw_memcmp()
Date: Tue, 11 Feb 2014 12:40:05 -0800
Message-ID: <20140211204005.GA5155@kroah.com>
References: <1391980559-24288-1-git-send-email-Larry.Finger@lwfinger.net>
 <1391980559-24288-2-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1391980559-24288-2-git-send-email-Larry.Finger@lwfinger.net>
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

On Sun, Feb 09, 2014 at 03:15:54PM -0600, Larry Finger wrote:
> This wrapper is replaced with a simple memcmp(). As the wrapper inverts the
> logic of memcmp(), care needed to be taken.

That's just evil, ugh, nice job...
