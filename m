From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 0/3] [LLC]: fixes for net-2.6 #2
Date: Fri, 28 Mar 2008 16:58:59 +0900
Message-ID: <b25c3fa70803280058h2d011c5fy7c79aff1daffc51e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, "Arnaldo Carvalho de Melo" <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:31776 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbYC1H7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 03:59:01 -0400
Received: by rv-out-0910.google.com with SMTP id k20so63815rvb.1
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 00:58:59 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is try #2 patchset for net-2.6 llc.

[PATCH 1/3] [LLC]: skb allocation size for responses
[PATCH 2/3] [LLC]: bogus llc packet length
[PATCH 3/3] [LLC]: station source mac address

Dave, Arnaldo, please review and consider applying.

Thanks,
Joonwoo
