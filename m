From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/3] Security: Add prctl(PR_{GET,SET}_NETWORK)
Date: Fri, 25 Dec 2009 18:09:08 +0100
Message-ID: <20091225170908.GA1581@ucw.cz>
References: <20091218154634.79decdc4@lxorguk.ukuu.org.uk> <20091218163348.GA24269@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
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
	Am?rico Wang <xiyou.wangcong@gmail.com>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091218163348.GA24269@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri 2009-12-18 11:33:48, Michael Stone wrote:
> Alan Cox wrote:
>
>> This is a security model, it belongs as a security model using LSM. 
>
> I'll see what I can cook up for you.
>
> However, please don't be surprised when the resulting cover letter states that
> the LSM-based version *does not* resolve the situation to my satisfaction as a
> userland hacker due to the well-known and long-standing adoption and
> compositionality problems facing small LSMs. ;)

Maybe it is time to fix the LSM? This excuse is much too common...
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
