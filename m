From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v2] mrf24j40: Fix en error handling path in
 'mrf24j40_probe()'
Date: Tue, 11 Jul 2017 08:48:33 +0200
Message-ID: <7CBE2DA8-9296-42F8-ACC4-9472C178753E@holtmann.org>
References: <20170708084013.18620-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alan Ott <alan@signal11.us>,
        Alexander Aring <alex.aring@gmail.com>,
        Stefan Schmidt <stefan@osg.samsung.com>,
        linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170708084013.18620-1-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Christophe,

> If this check fails, we must release some resources as done everywhere
> else in this function before returning an error code.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
> V2: initialization of ret in this erro path ws missing. Stupid me!
> ---
> drivers/net/ieee802154/mrf24j40.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
