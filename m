From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 18/23] e1000: revert 'e1000: Remove 0x1000 as supported
 device'
Date: Tue, 19 Sep 2006 15:40:47 -0400
Message-ID: <451047BF.6070907@pobox.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172913.4605.84224.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34236 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750773AbWISTku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 15:40:50 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060919172913.4605.84224.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> The commit 'e1000: Remove 0x1000 as supported device' (Jeff Kirsher,
> 673a052fde79ab5e9dce569b0336358812ddba2d) Removes PIC device ID 8086:1000
> from the list of supported devices. A fix was submitted for the original
> issue (commit 6a9516989f94df10d9a27ba543c6b53b3e69c84a).
> 
> This commit reverts commit 673a052fde79ab5e9dce569b0336358812ddba2d and
> re-enables 82542rev3 chips completely.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  0 files changed, 0 insertions(+), 0 deletions(-)

null patch


