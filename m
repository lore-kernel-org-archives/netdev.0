From: Patrick McHardy <kaber@trash.net>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: Fri, 25 Mar 2005 22:23:11 +0100
Message-ID: <4244813F.3010100@trash.net>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>	 <42408998.5000202@dsl.pipex.com>	 <1111550254.1089.21.camel@jzny.localdomain>	 <4241C478.5030309@dsl.pipex.com>	 <1111607112.1072.48.camel@jzny.localdomain>	 <4241D764.2030306@dsl.pipex.com>	 <1111612042.1072.53.camel@jzny.localdomain>	 <4241F1D2.9050202@dsl.pipex.com>  <4241F7F0.2010403@dsl.pipex.com>	 <1111625608.1037.16.camel@jzny.localdomain> <424212F7.10106@dsl.pipex.com>	 <1111663947.1037.24.camel@jzny.localdomain>	 <1111665450.1037.27.camel@jzny.localdomain>	 <4242DFB5.9040802@dsl.pipex.com>	 <1111749220.1092.457.camel@jzny.localdomain>	 <1111754346.1092.480.camel@jzny.localdomain>  <42444A14.3090809@trash.net>	 <1111775660.1092.571.camel@jzny.localdomain> <42445FFE.6040408@trash.net>	 <42446F7C.3000907@trash.net> <1111782705.1091.644.camel@jzny.loc
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Furniss <andy.furniss@dsl.pipex.com>,
        Harald Welte <laforge@gnumonks.org>, Remus <rmocius@auste.elnet.lt>,
        netdev <netdev@oss.sgi.com>, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Andre Tomt <andre@tomt.net>, syrius.ml@no-log.org,
        Damion de Soto <damion@snapgear.com>
To: hadi@cyberus.ca
In-Reply-To: <1111784056.1091.666.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> I think the attached script may help if you call it with something like
> 1000;
> You may need to adapt it slightly so you add the actions with new
> filters instead of directly. I would have to do a lot of plumbing from
> my scripts to give you one which does just that

The patch was wrong, sorry, index is initialized to -1. I'll have
another look at the second problem after getting something to eat.

Regards
Patrick
