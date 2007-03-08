From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH]: TCP RB tree core v2.
Date: Thu, 8 Mar 2007 06:21:03 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703080616480.27671@kivilampi-30.cs.helsinki.fi>
References: <20070307.123743.74748673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45214 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652AbXCHEVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 23:21:05 -0500
In-Reply-To: <20070307.123743.74748673.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Mar 2007, David Miller wrote:

> I checked the TCP write queue abstraction patch into the net-2.6.22
> GIT tree at:
> 
> 	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.22.git

While tried to apply your patch below, I noticed it's already there. It 
turns out that ebbe72e602c1e825c8ec97349095bdd286c0ff24 seems to 
be a mess, it includes also rbtree stuff you are giving below.

> And below is the current version of the second patch which actually
> does the RB tree stuff.

...snip...

-- 
 i.
