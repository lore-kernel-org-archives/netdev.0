From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] Remove pointless casts from void pointers,
Date: Fri, 26 Oct 2007 08:24:47 -0400
Message-ID: <20071026122447.GA23415@tuxdriver.com>
References: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org,
	rmk@arm.linux.org.uk, kernel@wantstofly.org, tony.luck@intel.com,
	jwboyer@linux.vnet.ibm.com, benh@kernel.crashing.org,
	paulus@samba.org, dmitry.torokhov@gmail.com,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-serial@vger.kernel.org, linux-wireless@vger.kernel.org,
	bryan.wu@analog.com, adaplas@gmail.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-serial-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 26, 2007 at 05:40:22AM -0400, Jeff Garzik wrote:
> mostly in and around irq handlers.
> 
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
> ---

>  drivers/net/wireless/airo.c                |    5 +++--
>  drivers/net/wireless/hostap/hostap_hw.c    |    2 +-
>  drivers/net/wireless/libertas/if_cs.c      |    2 +-

ACK

-- 
John W. Linville
linville@tuxdriver.com
