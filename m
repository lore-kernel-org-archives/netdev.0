From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 46/50] wan: use dev_hw_addr_random() instead of random_ether_addr()
Date: Thu, 09 Feb 2012 15:12:05 +0100
Message-ID: <m3vcng2j0q.fsf@intrepid.localdomain>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
	<1328735457-29986-47-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Danny Kukawka <dkukawka@suse.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-47-git-send-email-danny.kukawka@bisect.de>
	(Danny Kukawka's message of "Wed, 8 Feb 2012 22:10:53 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Danny Kukawka <danny.kukawka@bisect.de> writes:

> Use dev_hw_addr_random() instead of calling random_ether_addr()
> to set addr_assign_type correctly to NET_ADDR_RANDOM.
>
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
> ---
>  drivers/net/wan/hdlc_fr.c      |    2 +-
>  drivers/net/wan/hdlc_raw_eth.c |    2 +-

Acked-by: Krzysztof Halasa <khc@pm.waw.pl>
-- 
Krzysztof Halasa
