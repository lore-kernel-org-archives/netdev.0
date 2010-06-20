From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] net: optimize Berkeley Packet Filter (BPF) processing
Date: Sun, 20 Jun 2010 11:50:20 +0200
Message-ID: <20100620095019.GA32223@nuttenaction>
References: <1277003136-5522-1-git-send-email-hagen@jauu.net>
 <20100619221611.784f7dbc@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:44425 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756429Ab0FTJuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 05:50:22 -0400
Content-Disposition: inline
In-Reply-To: <20100619221611.784f7dbc@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Stephen Hemminger | 2010-06-19 22:16:11 [-0700]:

>I don't think this works because it breaks ABI compatibility for applications tha
>use older versions.

Are you sure Stephen? It is a one-to-one mapping of the ABI but maybe it was
too late yesterday ... ;-)


-- 
Hagen Paul Pfeifer <hagen@jauu.net>  ||  http://jauu.net/
Telephone: +49 174 5455209           ||  Key Id: 0x98350C22
Key Fingerprint: 490F 557B 6C48 6D7E 5706 2EA2 4A22 8D45 9835 0C22
