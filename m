From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Wed, 26 Nov 2014 07:06:04 -0500
Message-ID: <5475C22C.1060604@mojatatu.com>
References: <1416911328-10979-3-git-send-email-jiri@resnulli.us> <5474A25C.3080505@mojatatu.com> <5474A7EE.8000300@intel.com> <5474ABF0.60901@mojatatu.com> <5474AE9B.6000500@intel.com> <5474B353.10802@mojatatu.com> <CAE4R7bD1Hi+fnKp-Sg6Tn4AcpOu2pwgEYecP8LVA1ioO4FkgRQ@mail.gmail.com> <547546C5.3060207@mojatatu.com> <CAE4R7bA2VPZ3tm2MrsXAm4XfNX0TguT=vUma-3HrZSu98hBGyA@mail.gmail.com> <5475B952.2080500@mojatatu.com> <20141126114035.GM1875@nanopsycho.orion> <5475BF72.1060606@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:36339 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbaKZMGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 07:06:10 -0500
Received: by mail-ie0-f175.google.com with SMTP id at20so2398045iec.6
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 04:06:09 -0800 (PST)
In-Reply-To: <5475BF72.1060606@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14 06:54, Jamal Hadi Salim wrote:
> On 11/26/14 06:40, Jiri Pirko wrote:

>> Sure this is something that is reasonable to request. But that would
>> require a major changes to userspace api. At this moment, when we are
>> using the existing api, I would leave this out for phase 1. Let this be
>> resolved later as a separate work. Does that make sense?
>>
>
> I think these are just discussions so we know where we are going.
> I ACKed the patch already but added that we should consider these
> policies. Scott take note.
>

In case i wasnt clear - yes, the patch as is fine ;->

cheers,
jamal
