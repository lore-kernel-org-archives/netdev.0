From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sun, 22 May 2011 18:40:13 +0800
Message-ID: <BANLkTi=GpfFbV_WnrJcD8XCAtMyfiZwehg@mail.gmail.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
 <20110412.141645.112604563.davem@davemloft.net> <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
 <20110521072925.GA2588@jirka.orion> <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
 <4DD7BB61.9050200@gmail.com> <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
 <4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
 <BANLkTinEnHLx1CVh8p0ejLkcaqoLHw2nOA@mail.gmail.com> <20110522093758.GC2611@jirka.orion>
 <BANLkTin6u7VptTm3se_bLdEeTOz2OVc_Rw@mail.gmail.com> <m1wrhjni9p.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	=?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, Jesse Gross <jesse@nicira.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36822 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996Ab1EVKke convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 06:40:34 -0400
Received: by bwz15 with SMTP id 15so3999146bwz.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 03:40:33 -0700 (PDT)
In-Reply-To: <m1wrhjni9p.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 22, 2011 at 6:26 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> There is software emulation in dev_hard_start_xmit for the nics
> that don't support the feature. =A0So we will properly add tags.
>

Thanks. I got it. :)


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
