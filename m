From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 10/10 Rev4] [E1000] Implement batching
Date: Thu, 23 Aug 2007 08:14:32 +0530
Message-ID: <OFF62B08D8.4B722584-ON65257340.000EF898-65257340.000F1081@in.ibm.com>
References: <46CC4AA3.5030607@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	kaber@trash.net, jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	sri@us.ibm.com, shemminger@linux-foundation.org,
	davem@davemloft.net, rdreier@cisco.com
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46CC4AA3.5030607@intel.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Hi Auke,

"Kok, Auke" <auke-jan.h.kok@intel.com> wrote on 08/22/2007 08:09:31 PM:

> Krishna,
>
> while I appreciate the patch I would have preferred a patch to e1000e.
Not only
> does the e1000e driver remove a lot of the workarounds for old silicon,
it is
> also a good way for us to move the current e1000 driver into a bit more
stable
> maintenance mode.
>
> Do you think you can write this patch for e1000e instead? code-wise a lot
of
> things are still the same, so your patch should be relatively easy to
generate.
>
> e1000e currently lives in a branch from jeff garzik's netdev-2.6 tree

Definitely, I will pick it up and generate a patch.

Thanks,

- KK
