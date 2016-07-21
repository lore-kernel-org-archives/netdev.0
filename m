From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 3/3] bpf: make xdp sample variable names more
 meaningful
Date: Wed, 20 Jul 2016 18:22:27 -0700
Message-ID: <20160721012227.GD86045@ast-mbp.thefacebook.com>
References: <1469060555-20250-1-git-send-email-bblanco@plumgrid.com>
 <1469060555-20250-4-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:36128 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310AbcGUBWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 21:22:31 -0400
Received: by mail-yw0-f195.google.com with SMTP id u134so4535271ywg.3
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 18:22:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1469060555-20250-4-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2016 at 05:22:35PM -0700, Brenden Blanco wrote:
> The naming choice of index is not terribly descriptive, and dropcnt is
> in fact incorrect for xdp2. Pick better names for these: ipproto and
> rxcnt.
> 
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>

Thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>
