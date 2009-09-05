From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH net-next] wan: dlci/sdla transmit return dehacking
Date: Sat, 05 Sep 2009 13:09:57 +0200
Message-ID: <m3hbvhejga.fsf@intrepid.localdomain>
References: <20090904143439.c44f61ee.sfr@canb.auug.org.au>
	<20090903.213548.46609322.davem@davemloft.net>
	<20090904083346.43885303@nehalam>
	<m31vmmk0kt.fsf@intrepid.localdomain>
	<20090904193810.46543e3c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090904193810.46543e3c@nehalam> (Stephen Hemminger's message of
	"Fri, 4 Sep 2009 19:38:10 -0700")
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@vyatta.com> writes:

> In the Vyatta product we use the Sangoma drivers, so we actually have
> to make and not configure in the existing WAN drivers.

I'd expect all users of their hw are doing precisely the same (not to
imply there are any S5* (ISA) cards still in use).
But I don't know for sure, sometimes people use really old and long
unmaintained drivers with success. OTOH ISA...
-- 
Krzysztof Halasa
