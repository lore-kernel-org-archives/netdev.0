From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: ucc_geth: drop acquired references in probe
 error path and remove
Date: Fri, 08 Aug 2014 13:52:37 -0700 (PDT)
Message-ID: <20140808.135237.120203200807493642.davem@davemloft.net>
References: <1407448106-1819-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <20140808203456.GB5134@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, f.fainelli@gmail.com,
 kernel@pengutronix.de
To: u.kleine-koenig@pengutronix.de
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20140808203456.GB5134@pengutronix.de>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

RnJvbTogVXdlIEtsZWluZS1Lw7ZuaWcgPHUua2xlaW5lLWtvZW5pZ0BwZW5ndXRyb25peC5kZT4K
RGF0ZTogRnJpLCA4IEF1ZyAyMDE0IDIyOjM0OjU2ICswMjAwCgo+IEBkYXZlbTogU2hvdWxkIEkg
c2VuZCBhIGZpeHVwIG9yIGEgbmV3IHZlcnNpb24/CgpGaXh1cCwgcGxlYXNlLgpfX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpMaW51eHBwYy1kZXYgbWFpbGlu
ZyBsaXN0CkxpbnV4cHBjLWRldkBsaXN0cy5vemxhYnMub3JnCmh0dHBzOi8vbGlzdHMub3psYWJz
Lm9yZy9saXN0aW5mby9saW51eHBwYy1kZXY=
