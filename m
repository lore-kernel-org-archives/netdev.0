From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Mon, 7 Apr 2008 15:57:16 -0700 (PDT)
Message-ID: <312131.8802.qm@web36601.mail.mud.yahoo.com>
References: <200804071140.59247.paul.moore@hp.com>
Reply-To: casey@schaufler-ca.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Kentaro Takeda <takedakn@nttdata.co.jp>,
	Toshiharu Harada <haradats@nttdata.co.jp>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Paul Moore <paul.moore@hp.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <200804071140.59247.paul.moore@hp.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Paul Moore <paul.moore@hp.com> wrote:

> On Friday 04 April 2008 8:23:12 am Tetsuo Handa wrote:
> > This file contains modifications against kernel source code
> > needed to use TOMOYO Linux 1.6.
> >
> > Although LSM hooks are provided for performing access control,
> > TOMOYO Linux 1.6 doesn't use LSM because of the following reasons.
> 
> Hello,
> 
> I understand your frustration with the existing LSM hooks/API and your 
> reasoning for abandoning LSM in favor of a new set of hooks, however, I 
> think this sets a dangerous precedence which could result in an 
> abundance of security related hooks scattered throughout the kernel.  I 
> would much rather see the LSM API extended/tweaked to support the needs 
> of SAKURA and TOMOYO than ignored and duplicated; I suspect several 
> others will say the same.

The same.



Casey Schaufler
casey@schaufler-ca.com
