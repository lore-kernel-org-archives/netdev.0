From: Cong Wang <cwang@twopensource.com>
Subject: Re: Possible bug in tc tool or kernel
Date: Thu, 19 Mar 2015 10:40:36 -0700
Message-ID: <CAHA+R7Mmz_gXmWiZYbTe-xwfSH5LwiCu8BzWn-Xq1v53F=rTjA@mail.gmail.com>
References: <5507FA88.60303@eqv.ru>
	<CAHA+R7O__y1_czX74Ga1RSU-x8X0hUhs2Z01=vo37QUVkNniKQ@mail.gmail.com>
	<550AE10A.5080604@eqv.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?0KHQvtC70L7QstGM0LXQsiDQodC10YDQs9C10Lk=?= <sol@eqv.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36830 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754802AbbCSRki convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 13:40:38 -0400
Received: by igbud6 with SMTP id ud6so31417786igb.1
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 10:40:37 -0700 (PDT)
In-Reply-To: <550AE10A.5080604@eqv.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2015 at 7:45 AM, =D0=A1=D0=BE=D0=BB=D0=BE=D0=B2=D1=8C=D0=
=B5=D0=B2 =D0=A1=D0=B5=D1=80=D0=B3=D0=B5=D0=B9 <sol@eqv.ru> wrote:
> Checked. This patch is applied to my kernel and not fixes this proble=
m.
>
> tc as part of iproute2 freshed to latest 3.19.0 version, but nothing.=
=2E.
>
>

I got the same result with Vadim, on latest net-next.
