From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: of/phy: fix build error when phylib is built as a
 module
Date: Fri, 11 May 2012 17:24:55 -0400 (EDT)
Message-ID: <20120511.172455.120522633866860614.davem@davemloft.net>
References: <20120510.224352.2149006669429730060.davem@davemloft.net>
 <1336751221-19127-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: sfr@canb.auug.org.au, david.daney@cavium.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, paul.gortmaker@windriver.com,
 rdunlap@xenotime.net, linux-next@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org
To: bjorn@mork.no
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1336751221-19127-1-git-send-email-bjorn@mork.no>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

From: Bj=F8rn Mork <bjorn@mork.no>
Date: Fri, 11 May 2012 17:47:01 +0200

> Should be wrapped into commit 25106022 if it works, to ensure
> bisectability.

Wrapped into?

Commits made to my net-next tree are permanent and irreversible, so we
cannot go back and change a commit.  I never rebase my tree, too many
people use it directly and pull it into their tree, so I'd break their
world if I ever did that.
