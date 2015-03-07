From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH net-next 0/2] build fixes for iwlwifi
Date: Fri, 06 Mar 2015 20:35:22 -0600
Message-ID: <87fv9h7cwl.fsf@x220.int.ebiederm.org>
References: <874mpy2gw5.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <874mpy2gw5.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org> (Kalle Valo's message
	of "Fri, 06 Mar 2015 19:08:10 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


drivers/net/wireles/iwlwifi/mvm fails to build for me on
net-next.

Eric W. Biederman (2):
      iwlwifi: mvm: Fix the build of mvm/mac-ctxt.c with debugfs disabled
      iwlwifi: mvm: Fix the build of mvm/phy-ctxt.c with debugfs disabled

 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c | 7 ++++++-
 drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c | 2 ++
 2 files changed, 8 insertions(+), 1 deletion(-)


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
