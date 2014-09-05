From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support
 for datapath hardware offload
Date: Fri, 05 Sep 2014 06:46:02 -0400
Message-ID: <5409946A.9080708@mojatatu.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <20140904090447.GB3176@vergenet.net>
 <F4498A89-C1D6-4C5A-A6F0-942015D36B77@cumulusnetworks.com>
 <20140905040810.GB32481@vergenet.net>
 <E3C7797F-081E-484F-918E-937C705B43D6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Cc: Sergey Ryazanov <ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org,
 Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
 Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, ogerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
 Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
 Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, Aviad Raveh <aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>, dborkman <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Scott Feldman <sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <E3C7797F-081E-484F-918E-937C705B43D6-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
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

On 09/05/14 03:02, Scott Feldman wrote:

>> On Thu, Sep 04, 2014 at 09:30:45AM -0700, Scott Feldman wrote:
>>>

> Correct, for the particular switch implementation we=92re working with.

Do you have L2/3 working with this interface on said switch?
I am interested.

cheers,
jamal
