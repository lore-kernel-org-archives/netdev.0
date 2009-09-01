From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 1 Sep 2009 15:05:27 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909011504030.12112@V090114053VZO-1>
References: <20090901063726.GA5222@ff.dom.local> <alpine.DEB.1.10.0909011358030.15578@V090114053VZO-1> <4A9D2DBF.8030200@trash.net> <4A9D3687.2020101@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	davem@linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:34129 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753007AbZIAPGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 11:06:08 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0BAE082C65A
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 11:07:46 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MX6Yu59atuWm for <netdev@vger.kernel.org>;
	Tue,  1 Sep 2009 11:07:41 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 81CE682C74E
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 11:07:40 -0400 (EDT)
In-Reply-To: <4A9D3687.2020101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Sep 2009, Eric Dumazet wrote:

> Hmm, my bnx2 still displays correct info here (BCM5708S) ; so maybe Christoph has a
> real multiqueue NIC adapter ? I thought he mentioned a mono queue NIC earlier.

I have no clue if it is or not. I have never used those features.

dmesg says:

Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express

Is that a multiqueue adapter?
