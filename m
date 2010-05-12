From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 0/16] tipc: 1st integration of basic changes from sourceforge
Date: Tue, 11 May 2010 20:30:02 -0400
Message-ID: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35206 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136Ab0ELAaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:25 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0UOoW000081
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches are step one in making use of the changes that
were stored away on sourceforge but not yet integrated into the kernel.

Since I am far from knowledgeable on tipc, this starts by pulling in
the 1st batch of basic/cosmetic changes that will at least start to
reduce the delta between the two.   Hopefully getting all the simple
stuff out of the way 1st will help clarify what is left of interest.

I've also put the same commits on the branch tipc-May11_2010 in:
git://git.kernel.org/pub/scm/linux/kernel/git/paulg/net-next-2.6.git
in case that is more convenient for people.

Thanks,
Paul.

