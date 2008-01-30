From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] NET: constify data and function pointer tables
Date: Wed, 30 Jan 2008 11:11:13 -0500
Message-ID: <20080130161113.GB3317@tuxdriver.com>
References: <54038cd4f87a03884e4f59f8f3697889dfb63c54.1201030614.git.jengelh@computergmbh.de> <Pine.LNX.4.64.0801222046170.5722@fbirervta.pbzchgretzou.qr> <47A0427D.7040301@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh-bdq14YP6qtRlEiWPh9xO2Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <47A0427D.7040301-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 30, 2008 at 04:25:17AM -0500, Jeff Garzik wrote:
> Jan Engelhardt wrote:
>> Signed-off-by: Jan Engelhardt <jengelh-bdq14YP6qtRlEiWPh9xO2Q@public.gmane.org>
>> ---
>>  drivers/net/bonding/bond_main.c         |    2 +-
>>  drivers/net/hamradio/bpqether.c         |    2 +-
>>  drivers/net/hamradio/scc.c              |    2 +-
>>  drivers/net/hamradio/yam.c              |    2 +-
>>  drivers/net/ibmveth.c                   |    2 +-
>>  drivers/net/pppoe.c                     |    2 +-
>>  drivers/net/pppol2tp.c                  |    4 ++--
>>  drivers/net/wireless/libertas/debugfs.c |   14 +++++++-------
>>  drivers/net/wireless/strip.c            |    2 +-
>>  9 files changed, 16 insertions(+), 16 deletions(-)
>
> ACK -- but you should collect linville's ack of the wireless stuff too 
> (even though the patch is simple and obvious)

Looks fine to me...ACK

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
