From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Treewide frequency of various checkpatch messages
Date: Mon, 10 Mar 2014 09:50:46 -0700
Message-ID: <20140310165046.GA12687@kroah.com>
References: <1394104358-23438-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-1-git-send-email-kys@microsoft.com>
 <20140306.142919.763823800315842610.davem@davemloft.net>
 <1394148520.16156.8.camel@joe-AO722>
 <20140307075247.GA29018@mwanda>
 <1394184637.16156.58.camel@joe-AO722>
 <1394467346.24244.14.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, apw@canonical.com,
 devel@linuxdriverproject.org, Andrew Morton <akpm@linux-foundation.org>,
 David Miller <davem@davemloft.net>, Dan Carpenter <dan.carpenter@oracle.com>
To: Joe Perches <joe@perches.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1394467346.24244.14.camel@joe-AO722>
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

On Mon, Mar 10, 2014 at 09:02:26AM -0700, Joe Perches wrote:
> On Fri, 2014-03-07 at 01:30 -0800, Joe Perches wrote:
> > On Fri, 2014-03-07 at 10:54 +0300, Dan Carpenter wrote:
>  (a question about a new message warning of a missing
>   blank line between variable declaration blocks and
>   code in a function)
> > > How many warnings does this generate does this generate when you run it
> > > across the whole tree?
> > A lot.
> 
> Turns out it's 20,210 and it's the 14th
> most common checkpatch message type.
> 
>     14    20210  WARNING:SPACING: Missing a blank line after declarations

I think it's still worthwhile to clean up.

thanks,

greg k-h
