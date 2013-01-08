From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/5] ipv4_tunnels: Modularize ipv4 tunneling.
Date: Tue, 8 Jan 2013 13:20:02 -0800
Message-ID: <CALnjE+oUPJ6780b-o2Stz=+c+wsKOiPX0zyygah5g5hrArnBnw@mail.gmail.com>
References: <1357612292-1682-1-git-send-email-pshelar@nicira.com>
	<CAJZOPZK1wwno3wvu30v_HGm--R-SOYEP+SjK-sOc6F40iGb0QA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAJZOPZK1wwno3wvu30v_HGm--R-SOYEP+SjK-sOc6F40iGb0QA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Tue, Jan 8, 2013 at 1:10 PM, Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, Jan 8, 2013 at 4:31 AM, Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
>> Following patch series restructure GRE and IPIP tunneling code
>> to make it modular. It adds ip_tunnel module which acts as
>> generic tunneling layer which has common code. I have patch
>> to do same for VXLAN too. [..]
>
> Can you be more specific re the vxlan patch?
>

I am in process of updating VXLAN patches, I will send new version
soon. I have earlier version posted on openvswitch dev mailing list
last month.

Thanks,
Pravin.
