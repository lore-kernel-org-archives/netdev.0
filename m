From: Bryan O'Sullivan <bos@serpentine.com>
Subject: Re: [PATCH 2/5] [RFC] Infiniband: connection
	abstraction
Date: Wed, 18 Jan 2006 12:27:32 -0800
Message-ID: <1137616052.4757.85.camel@serpentine.pathscale.com>
References: <ORSMSX401FRaqbC8wSA0000003e@orsmsx401.amr.corp.intel.com>
	<ORSMSX401FRaqbC8wSA00000040@orsmsx401.amr.corp.intel.com>
	<20060117153838.3dc2cd2e@dxpl.pdx.osdl.net>
	<1137568107.3005.69.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, openib-general@openib.org,
	linux-kernel@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <openib-general-bounces@openib.org>
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1137568107.3005.69.camel@laptopd505.fenrus.org>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-01-18 at 08:08 +0100, Arjan van de Ven wrote:

> the dual license text needs a bit of clarification I suspect to make
> explicit that the "or BSD" part only applies when used entirely outside
> the linux kernel. (that already is the case, just it's not explicit.
> Making that explicit would be good).

One appropriate way to do that would be to mark all IB-related exported
symbols as EXPORT_SYMBOL_GPL.

	<b
