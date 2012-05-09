From: Gustavo Padovan <gustavo@padovan.org>
Subject: Re: [PATCH] net/bluetooth/bnep/core.c: use constant for ethertype
Date: Wed, 9 May 2012 01:09:01 -0300
Message-ID: <20120509040901.GC2362@joana>
References: <1336428575-28996-1-git-send-email-eldad@fogrefinery.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eldad Zack <eldad@fogrefinery.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1336428575-28996-1-git-send-email-eldad@fogrefinery.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eldad,

* Eldad Zack <eldad@fogrefinery.com> [2012-05-08 00:09:35 +0200]:

> The dot1q ethertype number (0x8100) is embedded in the code, although
> it is already defined in included headers.
> 
> Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
> ---
>  net/bluetooth/bnep/core.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Patch has been applied to bluetooth-next. Thanks.

	Gustavo
