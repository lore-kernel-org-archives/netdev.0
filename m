From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: [PATCH] fix BUG in tg3_tx
Date: Tue, 25 May 2004 18:22:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <B1508D50A0692F42B217C22C02D849727FEDBD@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Greg Banks" <gnb@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> 
> I believe the SGI-branded cards ship with firmware fixes 
> beyond simply changing the PCI ids.  Also, AFAIK it dates 
> from about the time of the TSO experiments.  Can you check if 
> that firmware has the issue you describe?
> 

TSO firmware is downloaded by the driver and not shipped with the card.
tg3 is using TSO firmware version 1.4.0 which is the latest for 5703 and
5704.

Michael
