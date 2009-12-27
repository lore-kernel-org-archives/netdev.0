From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Sun, 27 Dec 2009 13:45:07 +0100
Message-ID: <20091227124507.GB10661@basil.fritz.box>
References: <20091227010441.GA12077@heat> <200912271736.GDB17180.OFJHOOQStMFLVF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michael@laptop.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	andi@firstfloor.org, david@lang.hm, socketcan@hartkopp.net,
	alan@lxorguk.ukuu.org.uk, herbert@gondor.apana.org.au,
	Valdis.Kletnieks@vt.edu, bdonlan@gmail.com, zbr@ioremap.net,
	cscott@cscott.net, jmorris@namei.org, ebiederm@xmission.com,
	bernie@codewiz.org, mrs@mythic-beasts.com, randy.dunlap@oracle.com,
	xiyou.wangcong@gmail.com, sam@synack.fr, casey@schaufler-ca.com,
	serue@us.ibm.com, pavel@ucw.cz
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200912271736.GDB17180.OFJHOOQStMFLVF@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 27, 2009 at 05:36:48PM +0900, Tetsuo Handa wrote:
> Michael Stone wrote:
> > Further suggestions?
> 
> I expect that the future figure of this "disablenetwork" functionality becomes
> "disablesyscall" functionality.

That's basically apparmor. I believe it has been re-submitted 
recently.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
