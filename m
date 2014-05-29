From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next v3] mrf24j40: added device
 managed APIs
Date: Thu, 29 May 2014 12:45:16 +0200
Message-ID: <20140529104514.GA26416@omega>
References: <1401359258-7247-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alan@signal11.us, Varka Bhadram <varkab@cdac.in>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net, alex.aing@gmail.com,
	davem@davemloft.net
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1401359258-7247-1-git-send-email-varkab@cdac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Varka,


On Thu, May 29, 2014 at 03:57:38PM +0530, Varka Bhadram wrote:
> changes since v2:
> 1. removed unwanted label implementation. 
> 
> When we use devm_* APIs ,probe() failed also the memory
> will be freed automatically. Thanks to Alex
> 
> -Varka Bhadram
> 
> 

you should provide a "well" commit msg here. No emotional comments and
remove your signature.

Look in linux tree and run "git log" for other commit messages.

> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---

if you want to thanks somebody here and tell about the changes since v2
you can put it here, after the "---". This will be ignored while applying your patch.

>  drivers/net/ieee802154/mrf24j40.c |   30 ++++++++++++------------------
>  1 file changed, 12 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
> index 78a6552..f2b1345 100644
> --- a/drivers/net/ieee802154/mrf24j40.c
> +++ b/drivers/net/ieee802154/mrf24j40.c

- Alex
