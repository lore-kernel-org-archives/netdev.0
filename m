From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sun, 13 Feb 2005 01:00:10 +0300
Message-ID: <20050212220010.GA29417@yakov.inr.ac.ru>
References: <0525M9211@server5.heliogroup.fr> <420D37A3.6020209@hp.com> <20050211170958.17fcde21.davem@davemloft.net> <20050212143105.GB27456@yakov.inr.ac.ru> <86de38db09518ced8865af09cd79c064@hp.com> <20050212205617.GA29146@yakov.inr.ac.ru> <0db5e06aa50422877f9ec4a2e35d6795@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com,
        romieu@fr.zoreil.com, hubert.tonneau@fullpliant.org,
        shemminger@osdl.org
To: rick jones <rick.jones2@hp.com>
Content-Disposition: inline
In-Reply-To: <0db5e06aa50422877f9ec4a2e35d6795@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Is that in general, or in Linux?

Any which follows some of congestion window validation recommendations.
Even canonical bsd restarts slow start after rtt.


> N is something other than one though.

Well, 1 is quite enough to be sure that something is very wrong.
You see a proof here.

Alexey
