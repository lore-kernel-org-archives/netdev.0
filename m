From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/2] Minor cls_basic, act_bpf update
Date: Thu, 22 Jan 2015 10:58:17 +0100
Message-ID: <1421920699-26556-1-git-send-email-dborkman@redhat.com>
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751299AbbAVJ6X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 04:58:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann (2):
  net: cls_basic: return from walking on match in basic_get
  net: act_bpf: fix size mismatch on filter preparation

 net/sched/act_bpf.c   | 3 +++
 net/sched/cls_basic.c | 7 +++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

-- 
1.7.11.7
