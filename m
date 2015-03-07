From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH net-next 0/2] build fixes for iwlwifi
Date: Sat, 07 Mar 2015 09:27:00 +0200
Message-ID: <87r3t11d4r.fsf@kamboji.qca.qualcomm.com>
References: <874mpy2gw5.fsf@kamboji.qca.qualcomm.com>
	<87fv9h7cwl.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman),
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57176 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524AbbCGH1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 02:27:06 -0500
In-Reply-To: <87fv9h7cwl.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 06 Mar 2015 20:35:22 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebiederm@xmission.com (Eric W. Biederman) writes:

> drivers/net/wireles/iwlwifi/mvm fails to build for me on
> net-next.
>
> Eric W. Biederman (2):
>       iwlwifi: mvm: Fix the build of mvm/mac-ctxt.c with debugfs disabled
>       iwlwifi: mvm: Fix the build of mvm/phy-ctxt.c with debugfs disabled

Emmanuel, are you ok with these? Can I apply them?

-- 
Kalle Valo
