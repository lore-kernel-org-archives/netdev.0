From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/2] e1000: fix two mispatches
Date: Thu, 20 Apr 2006 17:31:25 -0400
Message-ID: <4447FDAD.4000904@pobox.com>
References: <20060418193950.16262.10757.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Miller, David" <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54172 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751331AbWDTVb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 17:31:27 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060418193950.16262.10757.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Hi,
> 
> This patch series implements two e100 fixes for an old and new patch mishap.
> 
> [1] fix mispatch for media type detect.
> [2] fix mismerge skb_put.
> 
> 
> These changes are available through git.
> 
> git://63.64.152.142/~ahkok/git/netdev-2.6 e1000-7.0.38-k2-fixes

applied


