From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] net: xdp: don't export dev_change_xdp_fd()
Date: Wed, 12 Apr 2017 11:21:16 +0200
Message-ID: <58EDF18C.5060002@iogearbox.net>
References: <20170412073207.27029-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60476 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753520AbdDLJVV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 05:21:21 -0400
In-Reply-To: <20170412073207.27029-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2017 09:32 AM, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
>
> Since dev_change_xdp_fd() is only used in rtnetlink, which must
> be built-in, there's no reason to export dev_change_xdp_fd().
>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
