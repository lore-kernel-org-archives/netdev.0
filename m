From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Thu, 3 Feb 2005 21:14:08 +0100
Message-ID: <20050203201408.GB3199@xi.wantstofly.org>
References: <20050202171702.24523.qmail@science.horizon.com> <1107365917.3754.155.camel@localhost.localdomain> <20050203115127.3245951f@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lorenzo =?iso-8859-1?Q?Hern=E1ndez_Garc=EDa-Hierro?= <lorenzo@gnu.org>,
        linux@horizon.com, mingo@elte.hu,
        Arjan van de Ven <arjan@infradead.org>, bunk@stusta.de,
        Chris Wright <chrisw@osdl.org>, davem@redhat.com,
        Hank Leininger <hlein@progressive-comp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, Valdis.Kletnieks@vt.edu, spender@grsecurity.net
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050203115127.3245951f@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Feb 03, 2005 at 11:51:27AM -0800, Stephen Hemminger wrote:

> Recent 2.6 does a more advanced form of port randomization already
> using address hash at connect time.  tcp_v4_get_port is only used for
> the case of applications that explicitly bind to port zero to find a
> free port.

Is any such randomisation done or planned for UDP?


--L
