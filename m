From: Martin Casado <casado-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: Open vSwitch Design
Date: Sat, 26 Nov 2011 00:05:25 -0800
Message-ID: <4ED09DC5.4000501@nicira.com>
References: <ec23d63d-27c9-4761-bdd3-e3f54bdb5e77@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Chris Wright <chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Stephen Hemminger <stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <ec23d63d-27c9-4761-bdd3-e3f54bdb5e77-bX68f012229Xuxj3zoTs5AC/G2K4zDHf@public.gmane.org>
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


> Not sure how Openvswitch implementation relates to Openflow specification.
The short answer is that Open vSwitch serves as one of the standard 
reference implementations for OpenFlow (in fact, the primary developers 
of Open vSwitch were some of the original designers of OpenFlow).  
Multiple hardware switches on the market use Open vSwitch as the basis 
for their OpenFlow support.
>
> There are a few switches supporting Openflow already:
>    http://www.openflow.org/wp/switch-nec/
>    http://www-03.ibm.com/systems/x/options/networking/bnt8264/index.html

There are many other ports announced or available from vendors such as 
HP, Brocade, Pica8, Extreme, Juniper, and NetGear.  Cisco has even 
announced support support for OpenFlow on the Nexus 3k 
(http://www.lightreading.com/document.asp?doc_id=213545).

.martin

>
> The standard(s) are here:
>    http://www.openflow.org/wp/documents/
>
> Good info from recent symposium:
>   http://opennetsummit.org/past_conferences.html
> _______________________________________________
> dev mailing list
> dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
> http://openvswitch.org/mailman/listinfo/dev


-- 
~~~~~~~~~~~~~~~~~~~~~~~~~~~
Martin Casado
Nicira Networks, Inc.
www.nicira.com
cell: 650-776-1457
~~~~~~~~~~~~~~~~~~~~~~~~~~~
