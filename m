From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Re: 2.6.26/tg3 ping roundtrip times > 2000 ms on local network
Date: Thu, 21 Aug 2008 18:09:28 +0200
Message-ID: <20080821160928.GB21967@torres.zugschlus.de>
References: <20080819172019.GA5823@torres.zugschlus.de> <20080819.132040.188336475.davem@davemloft.net> <1219166962.13090.12.camel@HP1> <20080819221439.GA19106@torres.zugschlus.de> <20080819223025.GA11221@xw6200.broadcom.net> <20080820174752.GB18419@torres.zugschlus.de> <1219241510.10902.12.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Matthew Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757385AbYHUQJq@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1219241510.10902.12.camel@HP1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 20, 2008 at 07:11:50AM -0700, Michael Chan wrote:
> On Wed, 2008-08-20 at 10:47 -0700, Marc Haber wrote:
> > Now I need to understand why the other, nearly[1] identical box didn't
> > need the patch to function properly.
> 
> It depends on whether you have ASF enabled or not and what version of
> ASF you have.  ASF is management firmware running inside the NIC.  When
> the tg3 driver loads, it will show ASF[1] in dmesg if ASF is enabled.

Both machines have that string in their dmesg.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
