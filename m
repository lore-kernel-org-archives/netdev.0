From: Dominique Martinet <asmadeus@codewreck.org>
Subject: Re: [V9fs-developer] [PATCH] net/9p: convert to new CQ API
Date: Tue, 8 Mar 2016 15:38:37 +0100
Message-ID: <20160308143837.GA10208@nautica>
References: <1456565151-27115-1-git-send-email-hch@lst.de>
 <1456565151-27115-2-git-send-email-hch@lst.de>
 <20160227154957.GA21186@nautica>
 <20160303083606.GA13828@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nautica.notk.org ([91.121.71.147]:51066 "EHLO nautica.notk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932435AbcCHOi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 09:38:59 -0500
Content-Disposition: inline
In-Reply-To: <20160303083606.GA13828@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Hellwig wrote on Thu, Mar 03, 2016:
> New version with the nits fixed below.  Now that checkpath started
> a stupid warning about not using tabs for indentation which I've
> ignored here and will take up in my usual fights against Joes
> idicotic opinions separately..

Thanks for the nitpicks, I can confirm it works as expected as well so
all good with me.
I like the new CQ interface :)

(if someone adds an Acked-by please use dominique.martinet@cea.fr for my
mail; sorry for the split personality)

-- 
Dominique
