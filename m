From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] MAINTAINERS: Update Open vSwitch entry.
Date: Fri, 2 Jan 2015 10:54:09 -0800
Message-ID: <CALnjE+ojnnVqVt4_-tNt5W8gNdNOwZEZ2jaOkKb9CxRhdaET-Q@mail.gmail.com>
References: <1420223098-1591-1-git-send-email-pshelar@nicira.com>
	<1420224077.23591.2.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:59761 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752016AbbABSyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 13:54:10 -0500
Received: by mail-ie0-f171.google.com with SMTP id ar1so17118897iec.30
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 10:54:09 -0800 (PST)
In-Reply-To: <1420224077.23591.2.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 2, 2015 at 10:41 AM, Joe Perches <joe@perches.com> wrote:
> On Fri, 2015-01-02 at 10:24 -0800, Pravin B Shelar wrote:
>> OVS development is moved to netdev mailing list. Update tree and
>> list in MAINTAINERS file.
> []
>> diff --git a/MAINTAINERS b/MAINTAINERS
> []
>> @@ -7008,9 +7008,11 @@ F:     arch/openrisc/
>>
>>  OPENVSWITCH
>>  M:   Pravin Shelar <pshelar@nicira.com>
>> +L:   netdev@vger.kernel.org
>>  L:   dev@openvswitch.org
>>  W:   http://openvswitch.org
>> -T:   git git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git
>> +T:   git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
>> +T:   git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
>>  S:   Maintained
>>  F:   net/openvswitch/
>>
>
> Are those git entries really appropriate?
>

I am not maintaining my tree on kernel.org. All OVS development will
be done on net-next tree, I guess there is no need to explicitly
mention the tree. I will remove the tree information.
