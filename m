From: Michael Stone <michael@laptop.org>
Subject: Re: [PATCH 1/3] Security: Add disablenetwork interface. (v4)
Date: Mon, 28 Dec 2009 20:21:58 -0500
Message-ID: <20091229012158.GA14362@heat>
References: <20091228181357.GB16277@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
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
	Pavel Machek <pavel@ucw.cz>, Michael Stone <michael@laptop.org>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091228181357.GB16277@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Serge Hallyn wrote:
> Is there any reason not to handle these in
>   disablenetwork_security_prctl()
> ?

I'm afraid that I don't understand what you're asking here. Are you just saying
that you'd like me to rename the functions that implement the interface logic
to something that begins with "disablenetwork_"?

Regards, and thanks for all your help,

Michael
