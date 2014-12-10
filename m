From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v6 7/7] libcxgbi: free skb after debug prints
Date: Wed, 10 Dec 2014 22:38:01 +0300
Message-ID: <5488A119.8080505@cogentembedded.com>
References: <201412101625.sBAGPSXC011110@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, anish@chelsio.com, hch@infradead.org,
	James.Bottomley@HansenPartnership.com, michaelc@cs.wisc.edu,
	davem@davemloft.net
To: Karen Xie <kxie@chelsio.com>, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:58588 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757594AbaLJTiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 14:38:06 -0500
Received: by mail-la0-f53.google.com with SMTP id gm9so2954412lab.40
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 11:38:04 -0800 (PST)
In-Reply-To: <201412101625.sBAGPSXC011110@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/10/2014 07:25 PM, Karen Xie wrote:

> [PATCH net v6 7/7] libcxgbi: free skb after debug prints

    Please, do not duplicate the subject in the changelog -- DaveM would have 
to edit it out by hand.

> From: Karen Xie <kxie@chelsio.com>

> The debug print was accessing the skb after it was freed.

> Signed-off-by: Karen Xie <kxie@chelsio.com>

WBR, Sergei
