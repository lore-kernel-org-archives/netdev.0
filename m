From: Daniel Drake <dsd@gentoo.org>
Subject: zd1211rw: Please revert commit
Date: Thu, 16 Nov 2006 17:32:12 -0500
Message-ID: <455CE6EC.1030401@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp151.iad.emailsrvr.com ([207.97.245.151]:46566 "EHLO
	smtp151.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1753527AbWKPWfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 17:35:05 -0500
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

A user reported that commit 4e1bbd846d00a245dcf78b6b331d8a9afed8e6d7 
(Remove unneeded packed attributes) breaks the zd1211rw driver on ARM. 
Please revert it for 2.6.19, we may attempt this change again at a later 
date.

Thanks,
Daniel
