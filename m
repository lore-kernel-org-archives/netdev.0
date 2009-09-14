From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Mon, 14 Sep 2009 17:10:57 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909141708150.8051@V090114053VZO-1>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1> <4AA7E082.90807@gmail.com>
 <alpine.DEB.1.10.0909091350590.32067@V090114053VZO-1> <4AA963A4.5080509@gmail.com> <4AA97183.3030008@gmail.com> <alpine.DEB.1.10.0909101741520.9964@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:43819 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752415AbZINVM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 17:12:57 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E9C7782C7A8
	for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 17:14:27 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 6-Pj-4Rd6Y2Q for <netdev@vger.kernel.org>;
	Mon, 14 Sep 2009 17:14:21 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D593D82C7A1
	for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 17:14:21 -0400 (EDT)
In-Reply-To: <alpine.DEB.1.10.0909101741520.9964@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Where are we on this? Definitely a regression?
