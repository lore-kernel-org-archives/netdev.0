From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [2.6 patch] net/bluetooth/: misc possible cleanups
Date: Tue, 14 Dec 2004 09:45:43 +0000
Message-ID: <20041214094543.GA963@infradead.org>
References: <20041214041352.GZ23151@stusta.de> <1103009649.2143.65.camel@pegasus>
Reply-To: bluez-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>, Max Krasnyansky <maxk@qualcomm.com>,
	bluez-devel@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development Mailing List <netdev@oss.sgi.com>
Return-path: <bluez-devel-admin@lists.sourceforge.net>
To: Marcel Holtmann <marcel@holtmann.org>
Content-Disposition: inline
In-Reply-To: <1103009649.2143.65.camel@pegasus>
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

On Tue, Dec 14, 2004 at 08:34:08AM +0100, Marcel Holtmann wrote:
> these functions must stay. They have users outside the mainline kernel
> that are not merged back yet. Otherwise they won't be exported ;)

But we traditionally don't keep APIs only for the sake of external modules.
Exceptions are made if you have short- to mid-term plans to merge them.



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
