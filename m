From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/3] rsi: Replace variable initialisations by assignments
 in rsi_send_data_pkt()
Date: Sat, 2 Jan 2016 16:07:44 +0100
Message-ID: <20160102150744.GA8926@electric-eye.fr.zoreil.com>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5687E169.4070704@users.sourceforge.net>
 <5687E27C.8000909@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Kalle Valo <kvalo@codeaurora.org>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5687E27C.8000909@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SF Markus Elfring <elfring@users.sourceforge.net> :
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 2 Jan 2016 15:25:34 +0100
> 
> Replace explicit initialisation for two local variables at the beginning
> by assignments.

It makes no sense for the 'adapter' variable.

-- 
Ueimor
