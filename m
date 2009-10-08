From: Gabriel Paubert <paubert@iram.es>
Subject: Re: Nested function in drivers/of/of_mdio.c
Date: Thu, 8 Oct 2009 13:14:27 +0200
Message-ID: <20091008111427.GA16941@iram.es>
References: <200910071715.57249.jezz@sysmic.org>
	<fa686aa40910070911x769d7d41u908fbcf6b0980962@mail.gmail.com>
	<f608b67d0910070923h54c30c2doae08550b0791ed1b@mail.gmail.com>
	<200910081045.12590.j.pouiller@sysmic.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org,
	Andy Fleming <afleming@freescale.com>,
	"David S. Miller" <davem@davemloft.net>
To: =?iso-8859-1?B?Suly9G1l?= Pouiller <j.pouiller@sysmic.fr>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <200910081045.12590.j.pouiller@sysmic.fr>
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

On Thu, Oct 08, 2009 at 10:45:12AM +0200, J=E9r=F4me Pouiller wrote:
> I did some grep on codebase. I have not found any other instances of =

> nested functions, but my regexps are not enough to be 100% sure.

>From Documentation/CodingStyle, written by the Head Penguin himself:

"Heretic people all over the world have claimed that this inconsistency
is ...  well ...  inconsistent, but all right-thinking people know that
(a) K&R are _right_ and (b) K&R are right.  Besides, functions are
special anyway (you can't nest them in C)."
                ^^^^^^^^^^^^^^^^^^^^^^^^

I interpret it as a clear prohibition of using nested functions
in the kernel.  =


	Regards,
	Gabriel
