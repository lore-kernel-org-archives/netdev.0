From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: linux-2.6.9 eepro100 warning
Date: Mon, 25 Oct 2004 15:27:49 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041025.152749.00307602.yoshfuji@linux-ipv6.org>
References: <200410232313.AA00003@prism.kumin.ne.jp>
	<417C9A4E.3030909@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakasima@kumin.ne.jp, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <417C9A4E.3030909@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <417C9A4E.3030909@pobox.com> (at Mon, 25 Oct 2004 02:16:46 -0400), Jeff Garzik <jgarzik@pobox.com> says:

> Note that eepro100 driver will be deleted soon.

I'm afraid that e100 does not work well on some systems (e.g. my ThinkPad
T30 on 2.4.x) while eepro100 does.
(I also know there're systems which does not work well
with eepro100 but e100.)

Has all of such kind of issues been solved?

--yoshfuji
