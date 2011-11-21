From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 5/5] net: Add Open vSwitch kernel
	components.
Date: Mon, 21 Nov 2011 15:23:14 -0800
Message-ID: <CAEP_g=-wpavbQ-tp6Cd0pBCzZ+kpG_nWBwPmSV-z_dymEoSLTA@mail.gmail.com>
References: <1321911029-20707-1-git-send-email-jesse@nicira.com>
	<1321911029-20707-6-git-send-email-jesse@nicira.com>
	<20111121141235.71a5f8fd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20111121141235.71a5f8fd-We1ePj4FEcvRI77zikRAJc56i+j3xesD0e7PPNI6Mm0@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 21, 2011 at 2:12 PM, Stephen Hemminger
<shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org> wrote:
> There are lots of new global symbols created by this module.
> Since C has no namespaces, a kernel module needs to in general
> stick to one prefix and naming convention.

That's a good point.  Thanks, I'll fix it.
