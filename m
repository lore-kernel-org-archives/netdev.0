From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next 0/3] cxgb4vf: fixes for several small issues discovered by QA
Date: Mon, 19 Jul 2010 18:12:10 -0700
Message-ID: <201007191812.10459.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3958 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757005Ab0GTBMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 21:12:16 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o6K1CFgg011649
	for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 18:12:15 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  A couple of small (but important) fixes discovered by our QA people.  I've also 
included a patch to add myself as the maintainer of cxgb4vf in the MAINTAINERS 
file which I think is the protocol but please correct me if changes to that file 
are usually performed by someone else.

Casey
