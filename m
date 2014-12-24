From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 4/6] bridge/link: add new offload hwmode swdev
Date: Wed, 24 Dec 2014 12:37:09 -0800
Message-ID: <20141224123709.6a68e094@urahara>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
	<1417683438-10935-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:54892 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbaLXUha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 15:37:30 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so10425029pdi.7
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 12:37:30 -0800 (PST)
In-Reply-To: <1417683438-10935-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  4 Dec 2014 09:57:16 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Scott Feldman <sfeldma@gmail.com>
> 
> To support full-featured switch devices offloading bridge funtionality,
> add new hwmode 'swdev'.  Like 'vepa' and 'veb', 'swdev' indicated bridge
> port functionality is being offloaded to hardware.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Please resubmit when the functionality is in net-next.
