From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/2] Update BPF documentation
Date: Tue, 10 Jun 2014 17:44:05 +0200
Message-ID: <1402415047-13535-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38297 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750835AbaFJPoN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2014 11:44:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set contains some important updates on the BPF documentation.
I have rebased the set on top of the pending rename in [1] that
touches one line from the doc as well, but actually there shouldn't
be conflicts either way. If so nevertheless, please let me know.

Thanks!

  [1] http://patchwork.ozlabs.org/patch/357025/

Alexei Starovoitov (2):
  net: filter: mention eBPF terminology as well
  net: filter: document internal instruction encoding

 Documentation/networking/filter.txt | 246 ++++++++++++++++++++++++++++++------
 1 file changed, 204 insertions(+), 42 deletions(-)

-- 
1.7.11.7
