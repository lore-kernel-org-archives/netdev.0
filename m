From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Pull request for 'r8169-for-jeff-20070919' branch
Date: Thu, 20 Sep 2007 22:44:37 +0200
Message-ID: <20070920204437.GB13512@electric-eye.fr.zoreil.com>
References: <20070919195606.GA3871@electric-eye.fr.zoreil.com> <46F2D24A.6050200@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, David Gundersen <gundy@iinet.net.au>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Sylvain Le Gall <sylvain@le-gall.net>,
	Roel.Teuwen@advalvas.be
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60706 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751136AbXITUsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 16:48:53 -0400
Content-Disposition: inline
In-Reply-To: <46F2D24A.6050200@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Ebbert <cebbert@redhat.com> :
[...]
> People are still reporting hangs with this card in 2.6.22.6, are there
> any fixes appropriate for that?

$ grep 2.6.22.6 ~/Mail/linux/bugs/pending
$ grep 2.6.22.6 ~/Mail/romieu
[nothing besides Sylvain's success with 2.6.22.6 + the r8169 test driver]
$ less +/2.6.22.6 ~/Mail/linux/netdev/200709 
[nada]
$ less +/816[89] ~/Mail/linux/kernel/200737
[...]

/me scratches head...

The answer is probably "not yet".

Can you refresh my memory with some #BZ or an url ?

-- 
Ueimor
