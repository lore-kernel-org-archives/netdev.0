From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 4/4] net: Add Open vSwitch kernel
	components.
Date: Tue, 22 Nov 2011 20:42:03 -0500 (EST)
Message-ID: <20111122.204203.590853592266420445.davem@davemloft.net>
References: <CAEP_g=8puZh8hihoyoHTc4f6cBu4jiDJQ6tqk6suQxR=dchyjA@mail.gmail.com>
	<20111122.181930.1186109067515095173.davem@davemloft.net>
	<CAEP_g=8EqkfRq4XmGy_8-f1FrXrvjHNBT6u70a_2mqDnyp2Miw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
To: jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=8EqkfRq4XmGy_8-f1FrXrvjHNBT6u70a_2mqDnyp2Miw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Date: Tue, 22 Nov 2011 17:34:57 -0800

> On Tue, Nov 22, 2011 at 3:19 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>> From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
>> Date: Tue, 22 Nov 2011 15:11:33 -0800
>>
>>> As you mention, one of the biggest benefits of Open vSwitch is how
>>> simple the kernel portions are (it's less than 6000 lines). =A0It's
>>> existed as an out-of-tree project for several years now so it's
>>> actually fairly mature already and unlikely that there will be a
>>> sudden influx of new code over the coming months.
>>
>> The packet scheduler classification and packet action infrastructure
>> has been around 5 times longer.
> =

> The only point that I was trying to make with that comment is that
> it's unlikely that Open vSwitch will suddenly get more complex due to
> the introduction of new code.

And it will get instantly less complex if it uses existing
infrastructure.

There is no reasonable argument against using what we have already.
