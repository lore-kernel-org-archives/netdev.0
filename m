From: Michael Stone <michael@laptop.org>
Subject: Re: [PATCH 1/3] Security: Add prctl(PR_{GET,SET}_NETWORK)
Date: Fri, 18 Dec 2009 11:33:48 -0500
Message-ID: <20091218163348.GA24269@heat>
References: <20091218154634.79decdc4@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091218154634.79decdc4@lxorguk.ukuu.org.uk>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox wrote:

> This is a security model, it belongs as a security model using LSM. 

I'll see what I can cook up for you.

However, please don't be surprised when the resulting cover letter states that
the LSM-based version *does not* resolve the situation to my satisfaction as a
userland hacker due to the well-known and long-standing adoption and
compositionality problems facing small LSMs. ;)

Regards,

Michael

P.S. - Dan is cited in my patch because I wish to honor him for anticipating my
desires early, clearly, and in writing. However, if you know of an earlier
citation, then I'll be happy to include that one too.
