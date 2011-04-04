From: Stefan Assmann <sassmann@kpanic.de>
Subject: Re: [PATCH 2/3] igb: transform igb_{update,validate}_nvm_checksum
 into wrappers of their *_with_offset equivalents
Date: Mon, 04 Apr 2011 09:23:51 +0200
Message-ID: <4D997207.7070509@kpanic.de>
References: <1301404186-20872-1-git-send-email-sassmann@kpanic.de> <1301404186-20872-3-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, jeffrey.t.kirsher@intel.com,
	alexander.h.duyck@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.xlhost.de ([213.202.242.118]:33726 "EHLO mysql1.xlhost.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751165Ab1DDHe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 03:34:27 -0400
In-Reply-To: <1301404186-20872-3-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.03.2011 15:09, Stefan Assmann wrote:
> igb_update_nvm_checksum_with_offset and igb_update_nvm_checksum are similar
> except one additionally handles an offset.
> Move igb_update_nvm_checksum_with_offset to e1000_nvm.c and transform
> igb_update_nvm_checksum to a simple wrapper of
> igb_update_nvm_checksum_with_offset.
> 
> Exactly the same is done for igb_validate_nvm_checksum.
> 
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>

Please ignore this for now, Intel will send a replacement patch.

  Stefan
