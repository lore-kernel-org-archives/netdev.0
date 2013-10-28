From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 1/3] vxlan: silence one build warning
Date: Mon, 28 Oct 2013 08:24:07 -0700
Message-ID: <20131028082407.03633f6b@nehalam.linuxnetplumber.net>
References: <1382940110-10737-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382940110-10737-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Oct 2013 14:01:48 +0800
Zhi Yong Wu <zwu.kernel@gmail.com> wrote:

> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>=20
> drivers/net/vxlan.c: In function =E2=80=98vxlan_sock_add=E2=80=99:
> drivers/net/vxlan.c:2298:11: warning: =E2=80=98sock=E2=80=99 may be u=
sed uninitialized in this function [-Wmaybe-uninitialized]
> drivers/net/vxlan.c:2275:17: note: =E2=80=98sock=E2=80=99 was declare=
d here
>   LD      drivers/net/built-in.o
>=20
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

This is much better.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
