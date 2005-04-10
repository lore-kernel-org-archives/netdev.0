From: jamal <hadi@cyberus.ca>
Subject: Re: [Fwd: Re: connector is missing in 2.6.12-rc2-mm1]
Date: 10 Apr 2005 10:39:19 -0400
Message-ID: <1113143959.1089.316.camel@jzny.localdomain>
References: <1112942924.28858.234.camel@uganda>
	 <E1DKZ7e-00070D-00@gondolin.me.apana.org.au>
	 <20050410143205.18bff80d@zanzibar.2ka.mipt.ru>
	 <1113131325.6994.66.camel@localhost.localdomain>
	 <20050410153757.104fe611@zanzibar.2ka.mipt.ru>
	 <20050410121005.GF26731@postel.suug.ch>
	 <20050410161549.3abe4778@zanzibar.2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Kay Sievers <kay.sievers@vrfy.org>,
	Herbert Xu <herbert@gondor.apana.org.au>, jmorris@redhat.com,
	ijc@hellion.org.uk, guillaume.thouvenin@bull.net, greg@kroah.com,
	linux-kernel@vger.kernel.org, akpm@osdl.org,
	netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261504AbVDJOjf@vger.kernel.org>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20050410161549.3abe4778@zanzibar.2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy,

Please crosspost on netdev - you should know that by now;->

I actually disagreee with Herbert on this. Theres definetely good
need to have a more usable messaging system that rides on top of
netlink. It is not that netlink cant be extended (I actually think thats
a separate topic) - its just that its usability curve is too high.
Thats what the original motivation for konnector was. To make it easy
for joe dumbass. And i think if konnector sticks to just doing that it
will end up being valuable.

I do think (and ive said this before) that Evgeniy is pushing it
by going beyond this simple agenda/focus. Unfortunately, I actually dont
think he is listening _at all_ on this specific issue. 

Evgeniy, just stick to the original focus and if it is accepted and
understood then lets move on to adding new features. Otherwise the
result of you adding yet one more feature for CBUS or whatever is
clearly to question what the original motivation was. And i dont think
you are able to add any other points to justify the existence of any new
konnector feature other than describe the original goals. At least thats
what i saw reading this thread. 
Otherwise if you really dont know what you want yet lets just pull this
whole thing out IMO.

cheers,
jamal
