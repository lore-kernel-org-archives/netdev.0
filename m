From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] wan/fsl_ucc_hdlc: avoid possible NULL pointer
 dereference
Date: Mon, 01 Aug 2016 13:44:53 -0700 (PDT)
Message-ID: <20160801.134453.885913890617619367.davem@davemloft.net>
References: <1469963663-3005-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org, qiang.zhao@nxp.com
To: xypron.glpk@gmx.de
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1469963663-3005-1-git-send-email-xypron.glpk@gmx.de>
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

RnJvbTogSGVpbnJpY2ggU2NodWNoYXJkdCA8eHlwcm9uLmdscGtAZ214LmRlPgpEYXRlOiBTdW4s
IDMxIEp1bCAyMDE2IDEzOjE0OjIzICswMjAwCgo+IEFsbCBhc3NpZ25tZW50cyB0byBjb21wb25l
bnRzIG9mIHByaXYgc2hvdWxkIG9ubHkKPiBvY2N1ciBhZnRlciB0aGUgY2hlY2sgaWYgcHJpZiBp
cyBOVUxMLgo+IAo+IFNpZ25lZC1vZmYtYnk6IEhlaW5yaWNoIFNjaHVjaGFyZHQgPHh5cHJvbi5n
bHBrQGdteC5kZT4KCkFwcGxpZWQuCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fCkxpbnV4cHBjLWRldiBtYWlsaW5nIGxpc3QKTGludXhwcGMtZGV2QGxpc3Rz
Lm96bGFicy5vcmcKaHR0cHM6Ly9saXN0cy5vemxhYnMub3JnL2xpc3RpbmZvL2xpbnV4cHBjLWRl
dg==
