From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: TG3 fix for slow switches (Was: TG3 driver failure on HP
 16-way)
Date: Tue, 31 May 2005 10:42:45 -0700
Message-ID: <1117561365.4310.22.camel@rh4>
References: <B1508D50A0692F42B217C22C02D84972020F3CED@NT-IRVA-0741.brcm.ad.broadcom.com>
 <20050531153819.GA20793@esmail.cup.hp.com>
 <1117560157.4310.16.camel@rh4>
 <20050531183653.GF20793@esmail.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        "Peter Chubb" <peterc@gelato.unsw.edu.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Grant Grundler" <iod00d@hp.com>
In-Reply-To: <20050531183653.GF20793@esmail.cup.hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-05-31 at 11:36 -0700, Grant Grundler wrote:
> On Tue, May 31, 2005 at 10:22:37AM -0700, Michael Chan wrote:
> > Thanks Grant, I'll chase this down and find a solution to this problem.
> 
> You mean you'll help find a way to reflash the onboard eeprom?
> 
No, I mean I will create a patch that will work for older devices that
do not have the valid LED bits in eeprom.

Thanks.
