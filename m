From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2 net-next] bridge: fix bugs introduced by
 last multicast patchset
Date: Thu, 12 Jun 2014 11:00:42 -0700 (PDT)
Message-ID: <20140612.110042.301380151424639820.davem@davemloft.net>
References: <1402530084-15061-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: linus.luessing@web.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1402530084-15061-1-git-send-email-linus.luessing@web.de>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Linus L=FCssing <linus.luessing@web.de>
Date: Thu, 12 Jun 2014 01:41:22 +0200

> Once my last patchset got applied, I got slapped by an automatic smat=
ch
> and build bot. Here are two patches fixing the according issues, a po=
tential
> null pointer dereference and a compile error when compiling without I=
Pv6.

Series applied, thanks.
