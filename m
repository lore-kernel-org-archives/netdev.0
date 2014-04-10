From: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Subject: Re: [PATCH 1/5] wil6210: Convert to Kbuild
Date: Thu, 10 Apr 2014 15:37:45 +0300
Message-ID: <9443559.tzNazhYoXT@lx-vladimir>
References: <1396946179-11677-1-git-send-email-qca_vkondrat@qca.qualcomm.com> <1949326.Ead3K8R9Y2@lx-vladimir> <53467B23.6000407@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Joe Perches <joe@perches.com>,
	"John W . Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <wil6210@qca.qualcomm.com>,
	netdev <netdev@vger.kernel.org>
To: Michal Marek <mmarek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:42904 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030461AbaDJMht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 08:37:49 -0400
In-Reply-To: <53467B23.6000407@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, April 10, 2014 01:06:11 PM Michal Marek wrote:
> It's up to you, since it's your driver :).

Then, I like Kbuild + Makefile better. This makes it clear
kbuild file is not 'real' top-level makefile.
So, let's keep this patch as it is.

Thanks, Vladimir
