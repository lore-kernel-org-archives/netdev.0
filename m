From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 00/10] introduce rocker switch driver with
 hardware accelerated datapath api - phase 1: bridge fdb offload
Date: Mon, 10 Nov 2014 07:16:16 -0500
Message-ID: <5460AC90.9060607@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <5460319B.2010605@mojatatu.com> <20141110072301.GA1850@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:63958 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567AbaKJMQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 07:16:22 -0500
Received: by mail-ig0-f182.google.com with SMTP id hn18so8966678igb.9
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 04:16:21 -0800 (PST)
In-Reply-To: <20141110072301.GA1850@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14 02:23, Jiri Pirko wrote:

>
> Yes I looked over their patches. Roopas patche's are about new class of
> device which, as I commented in the cover letter, I left out for now and
> can be safely added later on.
>
> I went over the Ben's work very carefully as well. The patches are very
> rough, mostly rtl-chip specific. But again, my patchset is a base on
> which this patches can be build on. I see no issues in that.
>
>> At least please get their sign on - this  is such an important piece of
>> new work that you should make sure you get consensus.
>
> Since I did not use their code now, I only put sign off of Scott.
>

Your last comment was "i am going to merge the patches" ;->
At least send an email explaining your plan to people who have worked
hard to cooperate with you or say it in the cover letter.

>> Otherwise we are back to square one and everyone is going their way with
>> their patches;
>
> I do think that we are in sync. I do not see any counter ways. As I
> said, their work can be added on to the base made of this patchset.
>

Ok, I hope so. I spoke for myself - it is important for this patches
you get their sign-on in my opinion.

cheers,
jamal
