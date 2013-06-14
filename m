From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 0/4] openvswitch tunneling preparation
Date: Fri, 14 Jun 2013 15:28:35 -0700
Message-ID: <CAEP_g=-SYXBEEKgCkOgrP3yQ7o7ZnneRDcOjR4pMaRrvnUtehQ@mail.gmail.com>
References: <1371147079-29139-1-git-send-email-pshelar@nicira.com>
 <20130613.170527.243134340140974936.davem@davemloft.net> <CAEP_g=9fV07wM-LVyfyMy9mjKe+y3pkGz8WvbZAPtM096m7ftw@mail.gmail.com>
 <20130614.140422.262779440905577037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:39843 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751512Ab3FNW25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 18:28:57 -0400
Received: by mail-ie0-f181.google.com with SMTP id x12so2439556ief.26
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 15:28:55 -0700 (PDT)
In-Reply-To: <20130614.140422.262779440905577037.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 14, 2013 at 2:04 PM, David Miller <davem@davemloft.net> wrote:
> From: Jesse Gross <jesse@nicira.com>
> Date: Fri, 14 Jun 2013 08:28:41 -0700
>
>> On Thu, Jun 13, 2013 at 5:05 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Pravin B Shelar <pshelar@nicira.com>
>>> Date: Thu, 13 Jun 2013 11:11:19 -0700
>>>
>>>> Following patches are required but not directly related to ovs tunneling.
>>>> So I am sending them as separate series. These cleanups are already
>>>> there in out of tree ovs module.
>>>>
>>>> Since ovs tunneling series depends on this, I am sending all patches
>>>> again.
>>>
>>> Openvswitch folks please send me a pull request.
>>
>> For the non-OVS portions of the tunneling series (not this one, which
>> I already applied, but the next) do you want to take them directly or
>> should I just throw them all into my tree?
>
> I was hoping you would send me a pull request for the initial 4 patch
> series et al.  Then get your ACK's for the openvswitch parts of the big
> tunneling patch set so that I could just apply the entire thing myself.

That works for me, I'll send the pull request now.
