From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH 0/2] net: finalize multicast list conversion
Date: Fri, 2 Apr 2010 09:21:27 +0200
Message-ID: <20100402072126.GA3100@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37294 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759257Ab0DBHVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 03:21:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset finalizes the conversion of multicast list to list_head. It also
moves the code manipulating all address lists to it's own file.

Jirka

