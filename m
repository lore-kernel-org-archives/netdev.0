From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/3] Security: Add disablenetwork interface. (v4)
Date: Mon, 28 Dec 2009 23:26:18 -0600
Message-ID: <20091229052618.GA23714@us.ibm.com>
References: <20091228181357.GB16277@us.ibm.com>
 <20091229012158.GA14362@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
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
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw.cz>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091229012158.GA14362@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Michael Stone (michael@laptop.org):
> Serge Hallyn wrote:
> >Is there any reason not to handle these in
> >  disablenetwork_security_prctl()
> >?
> 
> I'm afraid that I don't understand what you're asking here. Are you just saying
> that you'd like me to rename the functions that implement the interface logic
> to something that begins with "disablenetwork_"?

Sorry, for some reason I was thinking you still had a
security_operations *disablenetwork_ops.  But you don't, so
my comment is silly.  Please ignore.

> Regards, and thanks for all your help,

My pleasure, and thanks for the patience.

-serge
