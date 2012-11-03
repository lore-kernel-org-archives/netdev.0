From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 8/9] isdn: Remove unused variable causing a compile
 build warning
Date: Sat, 03 Nov 2012 23:40:41 +0100
Message-ID: <1351982441.1434.5.camel@x61.thuisdomein>
References: <1351980150-24145-1-git-send-email-lee.jones@linaro.org>
	 <1351980150-24145-9-git-send-email-lee.jones@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org
To: Lee Jones <lee.jones@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351980150-24145-9-git-send-email-lee.jones@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-11-03 at 23:02 +0100, Lee Jones wrote:
> This patch fixes:
> drivers/isdn/i4l/isdn_common.c: In function =E2=80=98isdn_ioctl=E2=80=
=99:
> drivers/isdn/i4l/isdn_common.c:1278:8: warning: unused variable =E2=80=
=98s=E2=80=99 [-Wunused-variable]

Did you have CONFIG_NETDEVICES not set in this build?


Paul Bolle
