From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 0/4] openvswitch tunneling preparation
Date: Fri, 14 Jun 2013 08:28:41 -0700
Message-ID: <CAEP_g=9fV07wM-LVyfyMy9mjKe+y3pkGz8WvbZAPtM096m7ftw@mail.gmail.com>
References: <1371147079-29139-1-git-send-email-pshelar@nicira.com> <20130613.170527.243134340140974936.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:47735 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752021Ab3FNP3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 11:29:03 -0400
Received: by mail-lb0-f180.google.com with SMTP id o10so719890lbi.39
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 08:29:02 -0700 (PDT)
In-Reply-To: <20130613.170527.243134340140974936.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 13, 2013 at 5:05 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Thu, 13 Jun 2013 11:11:19 -0700
>
>> Following patches are required but not directly related to ovs tunneling.
>> So I am sending them as separate series. These cleanups are already
>> there in out of tree ovs module.
>>
>> Since ovs tunneling series depends on this, I am sending all patches
>> again.
>
> Openvswitch folks please send me a pull request.

For the non-OVS portions of the tunneling series (not this one, which
I already applied, but the next) do you want to take them directly or
should I just throw them all into my tree?
