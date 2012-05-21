From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: linux-next: manual merge of the usb tree with the net-next tree
Date: Mon, 21 May 2012 09:16:57 +0300
Message-ID: <4FB9DDD9.8000506@qca.qualcomm.com>
References: <20120521161008.c0cc00b91642ed7a3875a686@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, <linux-next@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120521161008.c0cc00b91642ed7a3875a686@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/21/2012 09:10 AM, Stephen Rothwell wrote:

> Today's linux-next merge of the usb tree got a conflict in
> drivers/net/wireless/ath/ath6kl/usb.c between commit 9cbee358687e
> ("ath6kl: add full USB support") from the net-next tree and commit
> e1f12eb6ba6f ("USB: Disable hub-initiated LPM for comms devices") from
> the usb tree.
> 
> Just context changes.  I fixed it up (see below) and can carry the fix as
> necessary.

Is there anything I should do in ath6kl to handle the issue?

Kalle
