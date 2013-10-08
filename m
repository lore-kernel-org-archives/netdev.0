From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [PATCH net-next] Revert "xen-netback: improve ring effeciency
 for guest RX"
Date: Tue, 8 Oct 2013 11:21:47 +0100
Message-ID: <1381227707.3804.65.camel@hastur.hellion.org.uk>
References: <1381226061-6521-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	Annie Li <annie.li@oracle.com>, Matt Wilson <msw@amazon.com>,
	Xi Xiong <xixiong@amazon.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Paul Durrant <paul.durrant@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:55500 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756172Ab3JHKVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 06:21:51 -0400
In-Reply-To: <1381226061-6521-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-08 at 10:54 +0100, Wei Liu wrote:
> This reverts commit 4f0581d25827d5e864bcf07b05d73d0d12a20a5c.
> 
> The named changeset is causing problem. Let's aim to make this part less
> fragile before trying to improve things.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>

Although I thought davem would just run git revert so I don't know if it
is needed.
