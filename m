From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 00/12] openvswitch: gre tunneling support.
Date: Tue, 18 Jun 2013 08:47:06 -0700
Message-ID: <CALnjE+pKUZk4ZyHpCPZxKvfLNXySwxnewHHO00CBPLJAW_Nu=Q@mail.gmail.com>
References: <1371516561-17622-1-git-send-email-pshelar@nicira.com>
	<CAJZOPZLOA+NYux1baY820BR_hnNMZL6vnZW2G6Y8n2krwjOHdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:60129 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755589Ab3FRPrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 11:47:08 -0400
Received: by mail-qe0-f52.google.com with SMTP id i11so2535086qej.39
        for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 08:47:06 -0700 (PDT)
In-Reply-To: <CAJZOPZLOA+NYux1baY820BR_hnNMZL6vnZW2G6Y8n2krwjOHdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 17, 2013 at 11:21 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Tue, Jun 18, 2013 at 3:49 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> Following patch series adds support for gre tunneling.
>> First six patches extend kernel gre and ip_tunnel modules
>> api so that there is more code sharing between gre modules
>> and ovs. Rest of patches adds ovs tunneling infrastructre
>> and gre protocol vport.
>>
>> V2 fixes two patches according to comments from Jesse.
>
> Hi Pravin,
>
> I don't know what is the exact volume of changes between v1/v2 in this
> case, but generally,
> it would be very helpful if you make sure to spare few words on the
> actual changes between versions.

Patches that are changed has changelog in commit msg.
