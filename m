From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Thu, 27 Mar 2014 12:16:48 +0100
Message-ID: <20140327111648.GJ2845@minipsycho.orion>
References: <CAGVrzcbBq2=DG198NnpSWu52+uuundqQ-6QiiuzHF5X_j8fcZw@mail.gmail.com>
 <20140326173536.GJ2869@minipsycho.orion>
 <CAGVrzca84nbsyG3ETvn4nkgpMtYTh_dFDbzCywSdQ9uJjLVOUg@mail.gmail.com>
 <20140326181436.GL2869@minipsycho.orion>
 <53334BDA.1060608@mojatatu.com>
 <CAGVrzcaconDBjgSfk0=6px2+6LbrxMkmesgigSa3-9WaK-LiOw@mail.gmail.com>
 <20140327065616.GA2845@minipsycho.orion>
 <5333FFFF.1050005@mojatatu.com>
 <20140327105002.GH2845@minipsycho.orion>
 <53340787.1020807@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:43739 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754399AbaC0LQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 07:16:52 -0400
Received: by mail-ee0-f42.google.com with SMTP id d17so2755378eek.1
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 04:16:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <53340787.1020807@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 27, 2014 at 12:12:07PM CET, jhs@mojatatu.com wrote:
>On 03/27/14 06:50, Jiri Pirko wrote:
>>Thu, Mar 27, 2014 at 11:39:59AM CET, jhs@mojatatu.com wrote:
>
>>In my patchset, this is only for dummyswitch. The dummy switch driver
>>implementation. I provides a possibility for user to create these using
>>iplink.
>>
>
>Understood, but what is the motivation? ;-> Do you see some vendor
>SDK creating these?

No, dummyswitch is just for testing purposes and showing the swtichdev
API use. Nothing else. I most probably will not add it to the final
patchset proposal.

>
>cheers,
>jamal
