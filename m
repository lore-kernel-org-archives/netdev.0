From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [patch net-next RFC v2 0/6] introduce infrastructure
 for support of switch chip datapath
Date: Thu, 27 Mar 2014 10:03:10 -0400
Message-ID: <20140327140309.GD31168@tuxdriver.com>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <53334A3F.6020105@mojatatu.com>
 <20140327072107.GC2845@minipsycho.orion>
 <5333FD12.9060404@mojatatu.com>
 <20140327110223.GA1615@casper.infradead.org>
 <533408C0.8000608@mojatatu.com>
 <20140327120012.GA13573@casper.infradead.org>
 <53341A63.3000004@mojatatu.com>
 <20140327125711.GL2845@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140327125711.GL2845-RDzucLLXGGI88b5SBfVpbw@public.gmane.org>
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

On Thu, Mar 27, 2014 at 01:57:11PM +0100, Jiri Pirko wrote:
> Thu, Mar 27, 2014 at 01:32:35PM CET, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org wrote:
> >On 03/27/14 08:00, Thomas Graf wrote:
> >
> >>It seems like we reached pretty good consensus on the model. What
> >>remaining issues do you see with the port model proposed in v2?
> >>
> >
> >Are we really following the same thread?
> >I dont see any rallying behind Jiri's approach from the
> >other folks who have their own code and way of approaching things.
> >I am hoping we dont continue with the split that is there
> >already.
> 
> It is not a split. It is just a completion of a model. Adding missing
> parts. At least I see it that way.

I probably wouldn't call it a 'split' either.  But, I agree with
Jamal that we are nowhere near consensus so far.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
