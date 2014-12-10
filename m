From: Karen Xie <kxie@chelsio.com>
Subject: RE: [PATCH net v6 7/7] libcxgbi: free skb after debug prints
Date: Wed, 10 Dec 2014 20:26:59 +0000
Message-ID: <1442C3287A121140B690F7F20F94463D82F0A5@nice.asicdesigners.com>
References: <201412101625.sBAGPSXC011110@localhost6.localdomain6>,<5488A119.8080505@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Hariprasad S <hariprasad@chelsio.com>,
	Anish Bhatt <anish@chelsio.com>,
	"hch@infradead.org" <hch@infradead.org>,
	"James.Bottomley@HansenPartnership.com"
	<James.Bottomley@HansenPartnership.com>,
	"michaelc@cs.wisc.edu" <michaelc@cs.wisc.edu>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7343 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932707AbaLJU14 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 15:27:56 -0500
In-Reply-To: <5488A119.8080505@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, v7 has been submitted to address your comment. Please review.
________________________________________
From: Sergei Shtylyov [sergei.shtylyov@cogentembedded.com]
Sent: Wednesday, December 10, 2014 11:38 AM
To: Karen Xie; linux-scsi@vger.kernel.org; netdev@vger.kernel.org
Cc: Hariprasad S; Anish Bhatt; hch@infradead.org; James.Bottomley@HansenPartnership.com; michaelc@cs.wisc.edu; davem@davemloft.net
Subject: Re: [PATCH net v6 7/7] libcxgbi: free skb after debug prints

Hello.

On 12/10/2014 07:25 PM, Karen Xie wrote:

> [PATCH net v6 7/7] libcxgbi: free skb after debug prints

    Please, do not duplicate the subject in the changelog -- DaveM would have
to edit it out by hand.

> From: Karen Xie <kxie@chelsio.com>

> The debug print was accessing the skb after it was freed.

> Signed-off-by: Karen Xie <kxie@chelsio.com>

WBR, Sergei
