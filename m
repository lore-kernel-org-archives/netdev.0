From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] sched/cls_flow.c : allow nfct-* keys work on ingress interfaces
Date: Thu, 10 Dec 2015 10:46:40 -0800
Message-ID: <CAHA+R7P=8dg5M1VncpKW85XFOxY6HVL8Ery2v9F4CPz0QtEFPQ@mail.gmail.com>
References: <1498271449753849@web15j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?B?0JPQsNCy0YDQuNC70L7QsiDQmNCz0L7RgNGM?=
	<iggorok@yandex.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:36197 "EHLO
	mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbbLJSql convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 13:46:41 -0500
Received: by vkay187 with SMTP id y187so95947042vka.3
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 10:46:40 -0800 (PST)
In-Reply-To: <1498271449753849@web15j.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, Dec 10, 2015 at 5:24 AM, =D0=93=D0=B0=D0=B2=D1=80=D0=B8=D0=BB=D0=
=BE=D0=B2 =D0=98=D0=B3=D0=BE=D1=80=D1=8C <iggorok@yandex.ua> wrote:
> Improved CTTUPLE macro with code from sched/act_connmark.c, so it be =
able to get unNATed addresses from nf_conntrack.

Please follow the guideline to submit a formal kernel patch:
https://www.kernel.org/doc/Documentation/SubmittingPatches

Hints:
a) The patch has to be inlined
b) You have to sign it off
c) Please Cc the maintainers, in this case, Jamal Hadi Salim <jhs@mojat=
atu.com>
d) Use checkpatch.pl to check coding styles etc.

Thanks.
