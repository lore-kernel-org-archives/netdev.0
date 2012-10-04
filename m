From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [patch v3 02/11] inet_diag: pass inet_diag module to netlink_dump_start
Date: Thu, 04 Oct 2012 16:03:51 +0800
Message-ID: <506D42E7.1000203@cn.fujitsu.com>
References: <1349325689-16104-1-git-send-email-gaofeng@cn.fujitsu.com>  <1349325689-16104-2-git-send-email-gaofeng@cn.fujitsu.com> <1349327316.16011.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, steffen.klassert@secunet.com,
	netfilter-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	pablo@netfilter.org, stephen.hemminger@vyatta.com, jengelh@inai.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:36503 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932089Ab2JDIDx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 04:03:53 -0400
In-Reply-To: <1349327316.16011.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B410=E6=9C=8804=E6=97=A5 13:08, Eric Dumazet =E5=86=
=99=E9=81=93:
> I believe Pablo suggestion was to make netlink_dump_start()
> automatically pass THIS_MODULE so that we dont need to change all cal=
l
> sites ?

Yes, since you and Pablo both think this should be better,
I will resend this patchset.

Thanks!
