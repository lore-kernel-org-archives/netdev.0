From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next v3 01/17] bridge: rename fdb_*_hw to fdb_*_hw_addr
 to avoid confusion
Date: Tue, 25 Nov 2014 14:33:49 -0800
Message-ID: <547503CD.4010609@gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:62709 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbaKYWdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 17:33:53 -0500
Received: by mail-pd0-f169.google.com with SMTP id fp1so1430323pdb.14
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 14:33:53 -0800 (PST)
In-Reply-To: <1416911328-10979-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/11/14 02:28, Jiri Pirko wrote:
> The current name might seem that this actually offloads the fdb entry to
> hw. So rename it to clearly present that this for hardware address
> addition/removal.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

FWIW:

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
