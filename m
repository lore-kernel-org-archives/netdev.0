From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 09/28] Remove ATHEROS_AR231X
Date: Sun, 09 Feb 2014 20:43:33 +0100
Message-ID: <1391975013.25855.5.camel@x220>
References: <1391971686-9517-1-git-send-email-richard@nod.at>
	 <1391971686-9517-10-git-send-email-richard@nod.at>
	 <1391972955.3178.1.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Weinberger <richard@nod.at>,
	Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"open list:ATHEROS ATH5K WIR..." <linux-wireless@vger.kernel.org>,
	"open list:ATHEROS ATH5K WIR..." <ath5k-devel@lists.ath5k.org>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391972955.3178.1.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-02-09 at 11:09 -0800, Joe Perches wrote:
> On Sun, 2014-02-09 at 19:47 +0100, Richard Weinberger wrote:
> > The symbol is an orphan, get rid of it.
> 
> This description seems very incomplete as the symbol
> is being used quite a bit and the code the symbol
> controls is being deleted as well as the symbol.

Just yesterday I once again raised this issue (see
https://lkml.org/lkml/2014/2/8/248 ). My patch - which dates form May
2013 - removes quite a bit more than Richard's patch.


Paul Bolle
