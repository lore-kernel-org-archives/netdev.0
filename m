From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 0/5]qlcnic: vlan rx accleration support
Date: Thu, 16 Sep 2010 22:14:38 -0700
Message-ID: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:20821 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751537Ab0IQFOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Sep 2010 01:14:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
  Series v2 of 5 patches to support vlan rx accleration.
  This takes care of Eric Dumazet comment of using dev_kfree_skb(skb).
 
  I haven't combined accleration and GRO patch. Though its look strange
  with first patch. But I want to have separate patches for two different 
  entity.

-Amit
