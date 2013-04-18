From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use lockless genl.
Date: Thu, 18 Apr 2013 14:07:39 -0700
Message-ID: <CALnjE+rJ73hA3g6A1BVFbvgGzbYvLtYJpSWZLHr5hkjzKZEF_g@mail.gmail.com>
References: <1366303924-30701-1-git-send-email-pshelar@nicira.com>
	<CAEP_g=_17-e-up39hV9GFsLtYdeVLHqLKCkAc44bzGTaOt5jUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:44158 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751823Ab3DRVIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 17:08:05 -0400
Received: by mail-gg0-f197.google.com with SMTP id k5so4744183ggn.8
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 14:07:39 -0700 (PDT)
In-Reply-To: <CAEP_g=_17-e-up39hV9GFsLtYdeVLHqLKCkAc44bzGTaOt5jUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 18, 2013 at 11:31 AM, Jesse Gross <jesse@nicira.com> wrote:
> On Thu, Apr 18, 2013 at 9:52 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> Following patch uses of lockless genl callbacks for ovs.
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
> I think this is clearly the right thing to do (assuming that the genl
> part passes review from other people). However, can you expand the
> commit message for this patch a little bit to describe why it is safe
> and some of the benefits?
ok, I will send updated patch.
