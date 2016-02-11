From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: gigaset: memory leak in gigaset_initcshw
Date: Thu, 11 Feb 2016 23:34:53 +0100
Message-ID: <1455230093.4135.29.camel@tiscali.nl>
References: <CACT4Y+Y+P7-pM0D4HTz4ZF6i+Rya22eOkPdnrv_OmDCMB7eQtg@mail.gmail.com>
	 <1454516189.14366.8.camel@tiscali.nl>
	 <1454526665.14366.22.camel@tiscali.nl>
	 <CACT4Y+aDi8L_GELzVv7QM8YdtMD7q-wH4uO7LhioeSvaEU5PJg@mail.gmail.com>
	 <1454591389.14366.49.camel@tiscali.nl>
	 <CACT4Y+aXo83LjyOjVG2ihyR94kex-z+=Of+x8o4i+0q8964-1g@mail.gmail.com>
	 <1454593604.14366.65.camel@tiscali.nl>
	 <CACT4Y+b2z0NHVPQbyYP1CA_80hXxhk+VOG6dzduMEsi+27Pi7Q@mail.gmail.com>
	 <1454598375.14366.72.camel@tiscali.nl>
	 <CACT4Y+aNN8AAtRSvxxrP5RfsTZdd49odnQ_GRq86Y=jXr=pANw@mail.gmail.com>
	 <1454688387.28847.34.camel@tiscali.nl>
	 <1454697361.28847.39.camel@tiscali.nl>
	 <CACT4Y+Zw7V3h_Lt9kuF=fSht5qPz0CnmdwY0p+k0qr3b0KadpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	gigaset307x-common@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+Zw7V3h_Lt9kuF=fSht5qPz0CnmdwY0p+k0qr3b0KadpQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On vr, 2016-02-05 at 22:25 +0100, Dmitry Vyukov wrote:
> On Fri, Feb 5, 2016 at 7:36 PM, Paul Bolle <pebolle@tiscali.nl> wrote:
> > Does that make any difference?

> Nope.
> Almost 500 objects leaked in less than 10 seconds:

Too bad. Still a nice (potential) clean up though.

Thanks,


Paul Bolle
