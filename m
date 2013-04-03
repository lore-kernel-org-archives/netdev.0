From: Dave Jones <davej@redhat.com>
Subject: TCP: snd_cwnd is nul, please report this bug.
Date: Tue, 2 Apr 2013 23:54:28 -0400
Message-ID: <20130403035428.GA31709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23954 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759488Ab3DCDyb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 23:54:31 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r333sUXQ029497
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 2 Apr 2013 23:54:31 -0400
Received: from gelk.kernelslacker.org (ovpn-113-28.phx2.redhat.com [10.3.113.28])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r333sU8V015720
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 2 Apr 2013 23:54:30 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.6/8.14.5) with ESMTP id r333sTg6001336
	for <netdev@vger.kernel.org>; Tue, 2 Apr 2013 23:54:29 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.6/8.14.6/Submit) id r333sS5R001335
	for netdev@vger.kernel.org; Tue, 2 Apr 2013 23:54:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just had this warning on 3.9-rc5

Not sure what else to report.  Nothing really odd going on,
just some ssh traffic and firefox over wifi (iwlwifi)

anything else I can provide ?

	Dave
