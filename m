From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: BCM5721(tg3)&MSI
Date: Mon, 27 Jun 2005 00:29:23 -0700
Message-ID: <B1508D50A0692F42B217C22C02D84972067F0845@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Krzysztof Oledzki" <olel@ans.pl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Krzysztof Oledzki wrote:

> Oh, I see... BTW: What is wrong with AX/BX revisions?

Interrupts cannot be disabled properly in MSI mode.
