From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.11 4/8] tg3: Add msi test
Date: Tue, 22 Mar 2005 15:52:35 -0800
Message-ID: <20050322155235.267c4757.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3E2E@NT-IRVA-0741.brcm.ad.broadcom.com>
	<424098E2.6090007@pobox.com>
	<20050322141714.4515258f.davem@davemloft.net>
	<42409BA4.3090302@pobox.com>
	<20050322154030.310e85c1.davem@davemloft.net>
	<4240AF4C.9030109@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4240AF4C.9030109@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Mar 2005 18:50:36 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> Sorry, I still disagree.  We need to think about how to handle this 
> situation for -all- drivers and -all- users, not just tg3.

When you come up with something that doesn't require the users
to ask around and report stuff when MSI doesn't work, let me know.

But for now let's hold off on the tg3 MSI support, ok?
