From: Otavio Salvador <otavio@ossystems.com.br>
Subject: Re: [PATCH] net: phy: smsc: Implement PHY config_init for LAN87xx
Date: Thu, 27 Sep 2012 15:21:37 -0300
Message-ID: <CAP9ODKqC5PhkWxuMsFgA019-wZuygr_hhEme_xyP9dy4C6bLmw@mail.gmail.com>
References: <1348604262-21522-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org,
	Christian Hohnstaedt <chohnstaedt@innominate.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:40301 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754498Ab2I0SVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 14:21:38 -0400
Received: by pbbrr4 with SMTP id rr4so3968341pbb.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 11:21:37 -0700 (PDT)
In-Reply-To: <1348604262-21522-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 25, 2012 at 5:17 PM, Marek Vasut <marex@denx.de> wrote:
> The LAN8710/LAN8720 chips do have broken the "FlexPWR" smart power-saving
> capability. Enabling it leads to the PHY not being able to detect Link when
> cold-started without cable connected. Thus, make sure this is disabled.
>
> Signed-off-by: Marek Vasut <marex@denx.de>

Acked-by: Otavio Salvador <otavio@ossystems.com.br>

-- 
Otavio Salvador                             O.S. Systems
E-mail: otavio@ossystems.com.br  http://www.ossystems.com.br
Mobile: +55 53 9981-7854              http://projetos.ossystems.com.br
