From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove nested function
Date: Thu, 08 Oct 2009 02:10:25 -0700 (PDT)
Message-ID: <20091008.021025.13024270.davem@davemloft.net>
References: <fa686aa40910070911x769d7d41u908fbcf6b0980962@mail.gmail.com>
	<1254990863-15271-1-git-send-email-jezz@sysmic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	afleming@freescale.com
To: jezz@sysmic.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1254990863-15271-1-git-send-email-jezz@sysmic.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

From: J=E9r=F4me Pouiller <jezz@sysmic.org>
Date: Thu,  8 Oct 2009 10:34:23 +0200

> Some toolchains dislike nested function definition, so we define function=
 match
> outside of of_phy_find_device.
> =

> Signed-off-by: J=E9r=F4me Pouiller <jezz@sysmic.org>

Acked-by: David S. Miller <davem@davemloft.net>
