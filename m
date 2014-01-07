From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [GIT net-next] Open vSwitch
Date: Mon, 06 Jan 2014 19:49:01 -0500 (EST)
Message-ID: <20140106.194901.1806376120640813139.davem@davemloft.net>
References: <1389053776-62865-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1389053776-62865-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Date: Mon,  6 Jan 2014 16:15:59 -0800

> Open vSwitch changes for net-next/3.14. Highlights are:
>  * Performance improvements in the mechanism to get packets to userspace
>    using memory mapped netlink and skb zero copy where appropriate.
>  * Per-cpu flow stats in situations where flows are likely to be shared
>    across CPUs. Standard flow stats are used in other situations to save
>    memory and allocation time.
>  * A handful of code cleanups and rationalization.

Lots of good stuff in here, pulled, thanks Jesse.
