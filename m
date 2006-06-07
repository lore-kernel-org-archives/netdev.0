From: Diego Calleja <diegocg@gmail.com>
Subject: Updated sysctl documentation take #2
Date: Wed, 7 Jun 2006 20:53:16 +0200
Message-ID: <20060607205316.bbb3c379.diegocg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, linux-xfs@oss.sgi.com,
	ecki@lina.inka.de, lkml@rtr.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:33774 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932246AbWFGSzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 14:55:11 -0400
Received: by nf-out-0910.google.com with SMTP id x29so201205nfb
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2006 11:55:10 -0700 (PDT)
To: linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since people didn't like the "many small files" approach, I've moved
it to directories containing index.txt files:

Documentation/sysctl/vm/index.txt
Documentation/sysctl/net/core/index.txt
Documentation/sysctl/net/unix/index.txt
Documentation/sysctl/net/ipv4/index.txt
Documentation/sysctl/net/ipv4/conf/index.txt
Documentation/sysctl/net/ipv4/route/index.txt
Documentation/sysctl/net/ipv4/neigh/index.txt

and so on.

As previously, this moves all sysctl documentation (including
XFS and network) to Documentation/sysctl/*. The patch is
against linus tree and weights more than 200K in size
and is place at: http://www.terra.es/personal/diegocg/sysctl-docs

Comments?
