From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH v10] tilegx network driver: initial support
Date: Tue, 12 Jun 2012 09:14:31 -0400
Message-ID: <4FD740B7.8090203@tilera.com>
References: <4FCFA312.4020505@tilera.com> <20120606.115440.1245419453265419850.davem@davemloft.net> <201206072045.q57Kj2r1009249@farm-0002.internal.tilera.com> <20120611.170336.1197560839526564340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <bhutchings@solarflare.com>,
	<arnd@arndb.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120611.170336.1197560839526564340.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/11/2012 8:03 PM, David Miller wrote:
> From: Chris Metcalf <cmetcalf@tilera.com>
> Date: Thu, 7 Jun 2012 16:45:02 -0400
>
>> This change adds support for the tilegx network driver based on the
>> GXIO IORPC support in the tilegx software stack, using the on-chip
>> mPIPE packet processing engine.
>>
>> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> Applied.

Glad to hear it.  Thanks for bearing with the multiple revisions.  I (we)
appreciate all your feedback, and that of Ben, Eric, Arnd, and other folks
who contributed their time.

The driver does depend on tilegx iorpc framework code that is currently
only in linux-next, but it should all come together properly for 3.6.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
