From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Mon, 17 Aug 2009 18:13:38 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org> <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	Eric Dumazet <dada1@cosmosbay.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:56120 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753344AbZHQWNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 18:13:54 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1B00482C816
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 18:14:00 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id gWVQmgo2EXne for <netdev@vger.kernel.org>;
	Mon, 17 Aug 2009 18:13:55 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7215482C669
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 18:13:55 -0400 (EDT)
In-Reply-To: <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Aug 2009, Sridhar Samudrala wrote:

> What about ethtool -S ? Does it report any errors?

Neither. This is is a broadcom bnx2 NIC.

