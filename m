From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 6/6] openvswitch: Add vxlan tunneling support.
Date: Tue, 23 Jul 2013 16:48:44 -0700
Message-ID: <CALnjE+o7+q3aZm3xg6wY_HUEe9JRTxwNWAPSv4DJgA8xvWRUhQ@mail.gmail.com>
References: <1374603775-15605-1-git-send-email-pshelar@nicira.com>
	<CAJZOPZJH3UXC6BKLtUsDFAOvr=5cFHaY5_dSstBZNi-=HL_aiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	Jesse Gross <jesse@nicira.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog122.obsmtp.com ([74.125.149.147]:37800 "HELO
	na3sys009aog122.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933940Ab3GWXsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 19:48:45 -0400
Received: by mail-qc0-f173.google.com with SMTP id l10so4684098qcy.4
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 16:48:44 -0700 (PDT)
In-Reply-To: <CAJZOPZJH3UXC6BKLtUsDFAOvr=5cFHaY5_dSstBZNi-=HL_aiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 23, 2013 at 2:03 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Tue, Jul 23, 2013 at 9:22 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> [...]
>> --- /dev/null
>> +++ b/net/openvswitch/vport-vxlan.c
> [...]
>> +#ifdef CONFIG_OPENVSWITCH_VXLAN
>
> this should go to the makefile

OK.
