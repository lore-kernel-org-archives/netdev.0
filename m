From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [patch net-next RFC v2 0/6] introduce infrastructure
 for support of switch chip datapath
Date: Thu, 27 Mar 2014 12:00:12 +0000
Message-ID: <20140327120012.GA13573@casper.infradead.org>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <53334A3F.6020105@mojatatu.com>
 <20140327072107.GC2845@minipsycho.orion>
 <5333FD12.9060404@mojatatu.com>
 <20140327110223.GA1615@casper.infradead.org>
 <533408C0.8000608@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
 roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <533408C0.8000608-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 03/27/14 at 07:17am, Jamal Hadi Salim wrote:
> On 03/27/14 07:02, Thomas Graf wrote:
> >But wouldn't you want to introduce an additional ndo to
> >cover these?
> 
> We could - I just find it distracting at the current thread
> of discussion (the openwrt folks for example dont need any
> or most of that).
> 
> >What speaks against going with what Jiri proposes and adjust
> >& extend as needed as we go along?
> >
> 
> I was hoping we knock these issue one at a time. The noise right
> now is around ports and stacking of ports etc. Which in my
> opinion is an easier topic to handle.
> Jiri's patches on this can always come back in the discussion
> later.

It seems like we reached pretty good consensus on the model. What
remaining issues do you see with the port model proposed in v2?
