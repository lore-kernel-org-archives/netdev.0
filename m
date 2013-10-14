From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH -next] netdev: inet_timewait_sock.h missing semi-colon
 when KMEMCHECK is enabled
Date: Mon, 14 Oct 2013 14:25:51 -0700
Message-ID: <1381785951.12919.8.camel@joe-AO722>
References: <1381762088-18880-1-git-send-email-treding@nvidia.com>
	 <525C47C0.2000907@infradead.org> <1381780437.12919.3.camel@joe-AO722>
	 <525C5863.1000505@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Thierry Reding <thierry.reding@gmail.com>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mark Brown <broonie@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <525C5863.1000505@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-10-14 at 13:47 -0700, Randy Dunlap wrote:
> On 10/14/13 12:53, Joe Perches wrote:
> > On Mon, 2013-10-14 at 12:36 -0700, Randy Dunlap wrote:
> >> From: Randy Dunlap <rdunlap@infradead.org>
> >>
> >> Fix (a few hundred) build errors due to missing semi-colon when
> >> KMEMCHECK is enabled:

keyword: enabled...

> > Shouldn't this be done in kmemcheck.h?
> 
> This patch makes sense and probably should be merged
> but it does not fix the build errors that I reported.

Duh, enabled.  Yeah, you're sure...
