From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [PATCH] mac802154: fix sparse warning for mac802154_slave_get_priv
Date: Sat, 14 Jul 2012 07:42:43 +0400
Message-ID: <EE2B0AEB-F22F-499E-ACD8-0338A487F257@gmail.com>
References: <1342211770-4219-1-git-send-email-silviupopescu1990@gmail.com>
Mime-Version: 1.0 (iPhone Mail 8C148)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
To: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1342211770-4219-1-git-send-email-silviupopescu1990@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Make sparse happy by fixing the following error:
>    * symbol 'mac802154_slave_get_priv' was not declared. Should it be static?
> 
> Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
> ---
> net/mac802154/mib.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 

Should be already fixed, please try the latest net-next tree.