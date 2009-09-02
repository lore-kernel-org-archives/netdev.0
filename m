From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 1 Sep 2009 20:36:22 -0500 (CDT)
Message-ID: <alpine.DEB.1.10.0909012033500.32628@V090114053VZO-1>
References: <20090901063726.GA5222@ff.dom.local> <alpine.DEB.1.10.0909011358030.15578@V090114053VZO-1> <4A9D2DBF.8030200@trash.net> <4A9D3687.2020101@gmail.com> <alpine.DEB.1.10.0909011504030.12112@V090114053VZO-1> <4A9D3D9A.1030500@gmail.com>
 <alpine.DEB.1.10.0909011534350.12112@V090114053VZO-1> <4A9D410D.5000507@gmail.com> <4A9D448D.6050309@gmail.com> <alpine.DEB.1.10.0909011753230.25607@V090114053VZO-1> <20090901202432.GA3200@ami.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:43053 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752014AbZIAVhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 17:37:09 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6944582C5BC
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 17:38:48 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id A9+O6Z7jwCr2 for <netdev@vger.kernel.org>;
	Tue,  1 Sep 2009 17:38:43 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9490782C5EC
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 17:38:38 -0400 (EDT)
In-Reply-To: <20090901202432.GA3200@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Sep 2009, Jarek Poplawski wrote:

> Btw, isn't there something with your localhost's time?

Yup. I have virtual hosting and the provider screwed up time. I can do
nothing about it.
