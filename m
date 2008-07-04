From: "Matti Linnanvuori" <mattilinn@gmail.com>
Subject: [patch 1.2.32] WAN: merge driver retina
Date: Fri, 4 Jul 2008 09:39:03 +0300
Message-ID: <ca0148c30807032339o4182fbadq370f709a28861053@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:15715 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756712AbYGDGjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 02:39:04 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1081084wfd.4
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2008 23:39:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch is based on linux-next:
http://pcidriver.googlegroups.com/web/retina-patch.txt?gda=Hj6V2UEAAAD9a223ZdyQxc6jQf5toR434ka3fTOuf9SStRjUQ9KuyGG1qiJ7UbTIup-M2XPURDRb8A7WwO6f6JZwMwSZaAwRMXXBcZFbXU7ojtsMSuO4sA
The build error and the warnings reported by David Miller have been fixed.
