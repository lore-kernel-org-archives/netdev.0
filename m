From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Is File net/TUNABLE in kernel source still useful?
Date: Fri, 24 Jun 2011 15:06:23 +0800
Message-ID: <4E04376F.1040607@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?5Y2V5Y2r?= <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58887 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751736Ab1FXHF2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 03:05:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David=EF=BC=8C

 File net/TUNABLE has never be updated since git age.
 For some tunable parameters which user can control with proc file-syst=
em,
 They are all in ip-sysctl.txt doc.
 But for tunable parameters that only at compile time,
 Do we really need this document to maintain them?

 So many ones and seems no meaning.
 Directly send a patch to kill it, OK?

--=20
Best Regards
-----
Shan Wei
