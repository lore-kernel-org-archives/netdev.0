From: Stephen Hemminger <stephen@networkplumber.org>
Subject: pls merge net to net-next
Date: Tue, 16 Aug 2016 14:02:18 -0700
Message-ID: <20160816140218.3c6508b5@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Haiyang Zhang <haiyangz@microsoft.com>,
	KY Srinivasan <kys@microsoft.com>, netdev@vger.kernel.org
To: Vitaly Kuznetsov <vkuznets@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36262 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753335AbcHPVCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 17:02:53 -0400
Received: by mail-pa0-f44.google.com with SMTP id pp5so29610228pac.3
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 14:02:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since Vitaly's changes to hyperv drivers went into net it makes
it harder to submit other changes for net-next since they will invariably
cause conflicts.
