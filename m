From: Pravin Shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH net-next v13 7/8] openvswitch: add Ethernet
	push and pop actions
Date: Sat, 12 Nov 2016 15:57:57 -0800
Message-ID: <CAOrHB_Crfrdngydw-i9av2c-E68Gkje2jOfH1zG9LY3Zg_S3Vw@mail.gmail.com>
References: <cover.1478791347.git.jbenc@redhat.com>
	<fefa3d36d50639e176e831fefbc53d38ab2f04f6.1478791347.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <fefa3d36d50639e176e831fefbc53d38ab2f04f6.1478791347.git.jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 10, 2016 at 7:28 AM, Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> It's not allowed to push Ethernet header in front of another Ethernet
> header.
>
> It's not allowed to pop Ethernet header if there's a vlan tag. This
> preserves the invariant that L3 packet never has a vlan tag.
>
> Based on previous versions by Lorand Jakab and Simon Horman.
>
> Signed-off-by: Lorand Jakab <lojakab-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
> Signed-off-by: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Acked-by: Pravin B Shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>
