From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [patch net-next v5 06/21] net: introduce generic switch devices
 support
Date: Sat, 29 Nov 2014 11:44:07 +0100
Message-ID: <5479A377.3010406@gmx.de>
References: <1417181672-11531-1-git-send-email-jiri@resnulli.us> <1417181672-11531-7-git-send-email-jiri@resnulli.us> <5479927B.4020807@gmx.de> <20141129095902.GA1856@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvac
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:49923 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624AbaK2Kok (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Nov 2014 05:44:40 -0500
In-Reply-To: <20141129095902.GA1856@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.11.2014 10:59, Jiri Pirko wrote:

> 
> Lino, this was already discussed. So far there is no need to introduce
> such new infrastructure. But we have deal that once the need appears, it
> will be added (it easily can be).
> 
>>There is already an existing driver (see net/dsa) that addresses the
>>representation of switch devices. What is wrong with that?
> 
> This was already discussed as well. dsa is more of a driver for specific
> devices (has for example highly integrated mdio interface). There is
> also a deal to keep these 2 thing separated for now and try to merge
> that as much as we can in the future.
> 

I admit i did not follow the whole discussion. I was just wondering why
the existing dsa driver is not extended. But as you said it is planned
to do this in future. So thanks for your explanation.

Regards,
Lino
