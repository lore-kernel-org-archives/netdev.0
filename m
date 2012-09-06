From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: sctp_close/sk_free: kernel BUG at arch/x86/mm/physaddr.c:18!
Date: Thu, 6 Sep 2012 12:54:52 +0800
Message-ID: <20120906045452.GA18181@localhost>
References: <20120904140411.GB15068@localhost>
 <5046361C.5070602@pengutronix.de>
 <87mx15zfze.fsf@xmission.com>
 <20120905145508.GA9450@localhost>
 <50476931.20100@pengutronix.de>
 <1346859046.13121.144.camel@edumazet-glaptop>
 <1346859645.13121.146.camel@edumazet-glaptop>
 <1346864220.13121.157.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	networking <netdev@vger.kernel.org>, linux-can@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1346864220.13121.157.camel@edumazet-glaptop>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 05, 2012 at 06:57:00PM +0200, Eric Dumazet wrote:

> Here is a more complete patch, as there are three potential problems,
> not only one :

It's fine, too.

Tested-by: Fengguang Wu <wfg@linux.intel.com>

Thanks!
