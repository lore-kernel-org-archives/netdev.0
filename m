From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/3] net: Generalizations for GRE,GSO,GRO
Date: Tue, 11 Feb 2014 09:43:16 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1402110925300.6565@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ogerlitz@mellanox.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f201.google.com ([209.85.213.201]:59051 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790AbaBKRnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 12:43:17 -0500
Received: by mail-ig0-f201.google.com with SMTP id c10so1180108igq.0
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 09:43:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set contains some preliminary patches for Generic UDP
Encapsulation support. These generalize some uses of GRE, GSO, and
GRO.
