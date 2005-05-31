From: Grant Grundler <iod00d@hp.com>
Subject: Re: TG3 fix for slow switches (Was: TG3 driver failure on HP 16-way)
Date: Tue, 31 May 2005 12:03:45 -0700
Message-ID: <20050531190345.GH20793@esmail.cup.hp.com>
References: <B1508D50A0692F42B217C22C02D84972020F3CED@NT-IRVA-0741.brcm.ad.broadcom.com> <20050531153819.GA20793@esmail.cup.hp.com> <1117560157.4310.16.camel@rh4> <20050531183653.GF20793@esmail.cup.hp.com> <1117561365.4310.22.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <iod00d@hp.com>, "David S. Miller" <davem@davemloft.net>,
        Peter Chubb <peterc@gelato.unsw.edu.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1117561365.4310.22.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 31, 2005 at 10:42:45AM -0700, Michael Chan wrote:
> No, I mean I will create a patch that will work for older devices that
> do not have the valid LED bits in eeprom.

Ah ok. How can you know if the LED bits are valid (or not)?

I consider this a bug in the eeprom and have set things in motion
(in HP) to correct it since the card is not an obsolete product.

Otherwise, the patch I submitted should be sufficient.

thanks,
grant
