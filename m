From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] net/bluetooth/: misc possible cleanups
Date: Sun, 19 Dec 2004 17:07:58 +0100
Message-ID: <20041219160758.GY21288@stusta.de>
References: <20041214041352.GZ23151@stusta.de> <1103009649.2143.65.camel@pegasus>
Reply-To: bluez-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Max Krasnyansky <maxk@qualcomm.com>, bluez-devel@lists.sf.net,
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

> Hi Adrian,

Hi Marcel,

>...
> > Please comment on which of these changes are correct and which conflict 
> > with pending patches.
> 
> Please send a separate patch for all the RFCOMM changes, because these
> conflicts with some pending patches and then it will make it easier for
> me to merge them.
> 
> The rest of the changes are fine with me, but I like to see also a
> separate patch for the CMTP stuff and cmtp_send_capimsg() don't need a
> forward declaration. Simply move the function to another place in the
> source code.

splitted patches follow as reply to this email.

> Regards
> 
> Marcel

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
