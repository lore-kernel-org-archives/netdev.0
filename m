From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH] [504/2many] MAINTAINERS - USB PEGASUS
	DRIVER
Date: Mon, 13 Aug 2007 15:55:14 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708131553290.14743@bender.nucleusys.com>
References: <46bffc64.Are6NTp/45DX6lxZ%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-devel@lists.sourceforge.net,
	petkan@users.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org
To: joe@perches.com
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
In-Reply-To: <46bffc64.Are6NTp/45DX6lxZ%joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, 12 Aug 2007, joe@perches.com wrote:

> Add file pattern to MAINTAINER entry
>
> Signed-off-by: Joe Perches <joe@perches.com>
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index d822865..fc87fa7 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4764,6 +4764,7 @@ L:	linux-usb-devel@lists.sourceforge.net
> L:	netdev@vger.kernel.org
> W:	http://pegasus2.sourceforge.net/
> S:	Maintained
> +F:	drivers/net/usb/pegasus.*
>
> USB PRINTER DRIVER (usblp)
> P:	Pete Zaitcev
>

Well, what can i say?  "NO, don't do it!" is probably not going to work so 
i assume i will have to ACK.  :-)


 		Petko

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
