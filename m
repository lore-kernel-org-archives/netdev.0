From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [2.6 patch] net/bluetooth/: misc possible cleanups
Date: Tue, 14 Dec 2004 10:54:59 +0100
Message-ID: <1103018099.2143.127.camel@pegasus>
References: <20041214041352.GZ23151@stusta.de>
	 <1103009649.2143.65.camel@pegasus>  <20041214094543.GA963@infradead.org>
Reply-To: bluez-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, Max Krasnyansky <maxk@qualcomm.com>,
   BlueZ Mailing List <bluez-devel@lists.sourceforge.net>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Network Development Mailing List <netdev@oss.sgi.com>
Return-path: <bluez-devel-admin@lists.sourceforge.net>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20041214094543.GA963@infradead.org>
Sender: bluez-devel-admin@lists.sourceforge.net
Errors-To: bluez-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=bluez-devel>
List-Id: netdev.vger.kernel.org

Hi Christoph,

> > these functions must stay. They have users outside the mainline kernel
> > that are not merged back yet. Otherwise they won't be exported ;)
> 
> But we traditionally don't keep APIs only for the sake of external modules.
> Exceptions are made if you have short- to mid-term plans to merge them.

it is a short term plan, because otherwise I won't have submitted it in
the first place. And as I said, they are not merged back yet. They are
not tested enough for mainline at the moment.

Regards

Marcel




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
