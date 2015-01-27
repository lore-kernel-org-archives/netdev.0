From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: hyperv: else branch not necessary
Date: Tue, 27 Jan 2015 00:10:29 -0800 (PST)
Message-ID: <20150127.001029.277347255719163174.davem@davemloft.net>
References: <1422209317-18975-1-git-send-email-der.herr@hofr.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: der.herr@hofr.at
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1422209317-18975-1-git-send-email-der.herr@hofr.at>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <der.herr@hofr.at>
Date: Sun, 25 Jan 2015 19:08:37 +0100

> As the if completes with a unconditional goto the else branch
> is not needed here.
> 
> Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
> ---
> 
> v2: added missing subsystem string in subject line - patch unchanged

The feedback you were given was completely bogus.

Saying "net: " in addition to "hyperv: " is unnecessary, redundant,
and something you should not do.

Just plain "hyperv: " is complete and unambiguous enough to stand
upon itself.

Nobody says "net: ixgbe: " for Intel ethernet driver changes.  That's
just stupid.
