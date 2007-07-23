From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] [IrDA] KS959 USB IrDA dongle support
Date: Mon, 23 Jul 2007 11:13:15 +0100
Message-ID: <20070723111315.41e2b39f@the-village.bc.nu>
References: <20070722.183506.121297628.davem@davemloft.net>
	<kjg2gBqm.1185175506.5213420.samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"irda-users@lists.sourceforge.net" <irda-users@lists.sourceforge.net>,
	davem@davemloft.net,
	"linux-usb-devel@lists.sourceforge.net" <linux-usb-devel@lists.sourceforge.net>,
	"a_villacis@palosanto.com" <a_villacis@palosanto.com>
To: "Samuel Ortiz" <samuel@sortiz.org>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
In-Reply-To: <kjg2gBqm.1185175506.5213420.samuel@sortiz.org>
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

> >Too late, Linus just closed the merge window, you had two
> >weeks to submit this :-)
> Too bad...
> I submitted it as soon as it was ready. Will we have to wait until the
> 2.6.24 merge window, or can it be applied earlier as it's a fully
> standalone driver ?

You can always send Linus a copy and ask but if its just finished then
far better to send it to Andrew so that it can get testing and picked at
in -mm then merged next time around when polished.

Alan

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
