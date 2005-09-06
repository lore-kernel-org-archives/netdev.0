From: "Alejandro Bonilla" <abonilla@linuxwireless.org>
Subject: RE: [PATCH] wrong firmware location in IPW2100 Kconfig entry   (Was: IPW2100 Kconfig)
Date: Tue, 6 Sep 2005 12:51:26 -0600
Message-ID: <005901c5b313$fc974610$a20cc60a@amer.sykes.com>
References: <200509062048.29495.jesper.juhl@gmail.com>
Reply-To: <abonilla@linuxwireless.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<ipw2100-admin@linux.intel.com>,
	"'Roman Zippel'" <zippel@linux-m68k.org>,
	"'Sam Ravnborg'" <sam@ravnborg.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750794AbVIFSvf@vger.kernel.org>
To: "'Jesper Juhl'" <jesper.juhl@gmail.com>
In-Reply-To: <200509062048.29495.jesper.juhl@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Who should I send the "patch" to? Or can someone simply change that?

Jesper,

	Thanks. I also had a question. To whom is this patch sent to? Netdev or LK?
How does one determine?

.Alejandro

>
> Firmware should go into /lib/firmware, not /etc/firmware.
>
> Found by Alejandro Bonilla.
>
>
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
