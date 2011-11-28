From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: Issues with openflow protocol WAS(RE: [GIT PULL v2]
 Open vSwitch
Date: Mon, 28 Nov 2011 17:55:20 -0500
Message-ID: <1322520920.6118.42.camel@mojatatu>
References: <20111123075433.GA7928@gondor.apana.org.au>
	<1322050976.2039.125.camel@mojatatu>
	<20111128130409.GB16828@gondor.apana.org.au>
	<0199E0D51A61344794750DC57738F58E7586A74137@GVW1118EXC.americas.hpqcorp.net>
	<1322489230.7338.71.camel@mojatatu>
	<20124540-D566-41B0-B86F-0BCA19B948AA@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Fischer, Anna" <anna.fischer-VXdhtT5mjnY@public.gmane.org>,
	"dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20124540-D566-41B0-B86F-0BCA19B948AA-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

On Mon, 2011-11-28 at 10:44 -0800, Justin Pettit wrote:

> I realize you chair an IETF standard with overlapping goals with
> OpenFlow (ForCES), so you may have strong opinions about its design.

Yes, I do have strong opinions not really related to ForCES more towards
Linux. If i was to put ForCES in Linux (it is purely user space driven)
it would work with zero or small changes. 
And my non-Linux opinions are driven because I have implemented some of 
the things you folks are doing and look at them as advise more than
anything else.

> However, that's not relevant to this discussion, since OpenFlow's design
> has nothing to do with the discussion being held here in regards to Open
> vSwitch.  OpenFlow is just a bullet point--although an important one--in
> a large set of features that Open vSwitch provides.  Its design is such
> that it should be fairly easy to include new control protocols; OpenFlow
> is just a library in Open vSwitch.  If you have issues with OpenFlow,
> those would be better directed to the ONF or one of the OpenFlow mailing
> lists.


I am not subscribed to any of those - and besides that the openflow hype
at the moment is so high on that wave nobody will listen ;->
The only reason i keep bringing up openflow is because your architecture
in the minimal evolved from there (the fact you deal with flows and
actions and switches). I could stop talking about it if it is
offensive ;->

cheers,
jamal
