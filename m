From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH] mac802154: constify ieee802154_llsec_ops structure
Date: Mon, 4 Jan 2016 15:33:49 +0100
Message-ID: <20160104143344.GA18317@omega>
References: <1450906592-9203-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-wpan@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, marcel@holtmann.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1450906592-9203-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Dec 23, 2015 at 10:36:32PM +0100, Julia Lawall wrote:
> The ieee802154_llsec_ops structure is never modified, so declare it as
> const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 

Acked-by: Alexander Aring <alex.aring@gmail.com>

Marcel, can you please apply this on bluetooth-next?

Thank you.

- Alex
