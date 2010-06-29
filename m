From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [RFC][BUG-FIX] the problem of checksum checking in UDP protocol
Date: Tue, 29 Jun 2010 14:39:39 +0800
Message-ID: <4C29952B.6070704@cn.fujitsu.com>
References: <4C19E634.3030703@cn.fujitsu.com>	 <1277530086.2481.15.camel@edumazet-laptop>  <4C287E40.40906@cn.fujitsu.com> <1277757512.4235.750.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54416 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751629Ab0F2Glc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:41:32 -0400
In-Reply-To: <1277757512.4235.750.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, at 06/29/2010 04:38 AM:
> If a change is needed, I would vote for a change in NIC firmware,

Eric, thanks for your explanation very much.

My solution is ugly. Modify UDP protocol stack is just a way to circumv=
ent.=20
Most in need of modification should be the NIC's fireware.=E3=80=80Howe=
ver,
such as the e1000e network card for years, and no serious problems have=
 been reported.

So, I think this thread can be closed now.

--=20
Best Regards
-----
Shan Wei

