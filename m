From: kuznet@ms2.inr.ac.ru
Subject: Re: Frozen machine with adding a tc filter
Date: Tue, 23 Jul 2002 02:57:14 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200207222257.CAA14506@sex.inr.ac.ru>
References: <20020722212111.GA22916@outpost.ds9a.nl>
Mime-Version: 1.0
Cc: albertogli@telpin.COM.AR, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: ahu@ds9a.nl (bert hubert)
In-Reply-To: <20020722212111.GA22916@outpost.ds9a.nl> from "bert hubert" at Jul 22, 2 11:21:11 pm
List-Id: netdev.vger.kernel.org

Hello!

> I also reported this

Sorry, I do not remeber this.

>		 - should tc check this? Or the kernel?

The kernel. This funny feature was supposed to disappear ages ago, in 2.2.
It did not, hence, it did not. :-)


> Aren't the last 2 lines meant to prevent this from happening?

They are.


> Please tell me your ideas,

Well, before all figure out where it deadlocks.

Alexey
