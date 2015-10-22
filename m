From: Otto Sabart <osabart@redhat.com>
Subject: [BUG] bnx2x_config_vlan_mac called a NULL function pointer
Date: Thu, 22 Oct 2015 21:45:09 +0200
Message-ID: <20151022194509.GA14434@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ariel Elior <ariel.elior@qlogic.com>,
	Adam Okuliar <aokuliar@redhat.com>,
	Jirka Hladky <jhladky@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33915 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757893AbbJVTpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 15:45:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello netdev,
I probably found a bug in kernel-4.3.0-0.rc5 (bnx2x driver). So I opened
new bug report in our bugzilla [0]. Michal Schmidt told me the best way
to solve an upstream bug is to contact you directly to netdev list.. so
here I am :).

Can somebody take a look at it?

[0] https://bugzilla.redhat.com/show_bug.cgi?id=1273894


thanks,

Ota
