From: Nico Schottelius <nico-linux-20120113@schottelius.org>
Subject: Re: brcmsmac: 3.2.0-06100: no device shown (and hangs in 3.2.0-rc7)
Date: Fri, 13 Jan 2012 15:18:09 +0100
Message-ID: <20120113141809.GA3072@schottelius.org>
References: <20120113124559.GA2260@schottelius.org>
 <4F103379.2050904@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nico Schottelius <nico-linux-20120113@schottelius.org>,
	LKML <linux-kernel@vger.kernel.org>, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F103379.2050904@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Arend,

Arend van Spriel [Fri, Jan 13, 2012 at 02:36:57PM +0100]:
> Could this be on your MacBook Air? If so, Linus has flagged and solved
> this issue (see thread "brcm80211 breakage" on netdev mailer).

Oh, yes, indeed!

Although the channel 13 issue seems still to exist.

I'll apply his patches this evening and test as well.

Cheers,

Nico

-- 
PGP key: 7ED9 F7D3 6B10 81D7 0EC5  5C09 D7DC C8E4 3187 7DF0
