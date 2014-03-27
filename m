From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Thu, 27 Mar 2014 07:12:07 -0400
Message-ID: <53340787.1020807@mojatatu.com>
References: <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion> <CAGVrzcbBq2=DG198NnpSWu52+uuundqQ-6QiiuzHF5X_j8fcZw@mail.gmail.com> <20140326173536.GJ2869@minipsycho.orion> <CAGVrzca84nbsyG3ETvn4nkgpMtYTh_dFDbzCywSdQ9uJjLVOUg@mail.gmail.com> <20140326181436.GL2869@minipsycho.orion> <53334BDA.1060608@mojatatu.com> <CAGVrzcaconDBjgSfk0=6px2+6LbrxMkmesgigSa3-9WaK-LiOw@mail.gmail.com> <20140327065616.GA2845@minipsycho.orion> <5333FFFF.1050005@mojatatu.com> <20140327105002.GH2845@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Felix Fietkau <nbd@openwrt.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:37587 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755101AbaC0LMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 07:12:10 -0400
Received: by mail-ob0-f181.google.com with SMTP id wp4so4041801obc.40
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 04:12:09 -0700 (PDT)
In-Reply-To: <20140327105002.GH2845@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/14 06:50, Jiri Pirko wrote:
> Thu, Mar 27, 2014 at 11:39:59AM CET, jhs@mojatatu.com wrote:

> In my patchset, this is only for dummyswitch. The dummy switch driver
> implementation. I provides a possibility for user to create these using
> iplink.
>

Understood, but what is the motivation? ;-> Do you see some vendor SDK 
creating these?

cheers,
jamal
