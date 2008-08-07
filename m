From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] sh_eth Add SH7619 support (driver)
Date: Thu, 07 Aug 2008 02:23:37 -0400
Message-ID: <489A94E9.5050606@garzik.org>
References: <878wvhtynu.wl%ysato@users.sourceforge.jp>	<29ab51dc0807312048hfa9cd88pb90d1a7520bb3f99@mail.gmail.com>	<871w18ycmr.wl%ysato@users.sourceforge.jp>	<20080802073021.GA30041@verge.net.au>	<87myjv77nm.wl%ysato@users.sourceforge.jp>	<20080803192335.GB4448@linux-sh.org>	<87tzdzmfno.wl%ysato@users.sourceforge.jp>	<29ab51dc0808060038g429bed14q4f41ef654def2a0@mail.gmail.com> <87k5etzour.wl%ysato@users.sourceforge.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>,
	Paul Mundt <lethal@linux-sh.org>,
	Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: Yoshinori Sato <ysato@users.sourceforge.jp>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <87k5etzour.wl%ysato@users.sourceforge.jp>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yoshinori Sato wrote:
> Add support SH7619 Internal ethernet controler.
> 
>  arch/sh/include/asm/sh_eth.h |   11 +++++++
>  drivers/net/Kconfig          |    5 ++-
>  drivers/net/sh_eth.c         |   69 ++++++++++++++++++++++++++++++-----------
>  drivers/net/sh_eth.h         |   22 +++++++++++--
>  4 files changed, 82 insertions(+), 25 deletions(-)
>  create mode 100644 arch/sh/include/asm/sh_eth.h

applied


