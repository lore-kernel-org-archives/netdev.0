From: David Dillow <dave@thedillows.org>
Subject: Re: [BK netdev-2.6] Update Typhoon firmware
Date: Tue, 28 Dec 2004 00:39:25 -0500
Message-ID: <1104212365.4293.0.camel@ori.thedillows.org>
References: <1103314025.4217.1.camel@ori.thedillows.org>
	 <41CFD72C.6090503@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <41CFD72C.6090503@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-12-27 at 04:34 -0500, Jeff Garzik wrote:
> David Dillow wrote:
> > Jeff, please do a
> > 
> > 	bk pull http://typhoon.bkbits.net/typhoon-2.6-firmware
> 
> 
> [jgarzik@pretzel net-drivers-2.6]$ bk pull 
> http://typhoon.bkbits.net/typhoon-2.6-firmware
> Pull http://typhoon.bkbits.net/typhoon-2.6-firmware
>    -> file://garz/repo/net-drivers-2.6
> ERROR-cannot cd to typhoon-2.6-firmware (illegal, nonexistant, or not 
> package root)


Doh! Make that
bk pull http://typhoon.bkbits.net/typhoon-2.6


-- 
David Dillow <dave@thedillows.org>
