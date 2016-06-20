From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute PATCH 1/3] Use C99 style initializers everywhere
Date: Sun, 19 Jun 2016 21:39:41 -0600
Message-ID: <0e6807da-0046-d2b9-a0e1-7f0c88a2a1a3@cumulusnetworks.com>
References: <576420B0.3050203@iogearbox.net>
 <20160618000221.GA10428@orbyte.nwl.cc> <20160617172126.1d26262e@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"julien.floret@6wind.com" <julien.floret@6wind.com>
To: Stephen Hemminger <shemming@brocade.com>, Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33429 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbcFTDjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 23:39:44 -0400
Received: by mail-pa0-f50.google.com with SMTP id b13so46352637pat.0
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2016 20:39:43 -0700 (PDT)
In-Reply-To: <20160617172126.1d26262e@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/17/16 6:21 PM, Stephen Hemminger wrote:
> I want to have the least user complaints possible.
> Since the main reason people build new iproute2 utilities is to work with features
> of newer kernels. It makes sense to keep the requirements the same. Not sure if kernel
> still builds with gcc-3.2, has anyone tried.

That seems excessive.

Looking at the ftp sites RHEL4 started with gcc-3.4 in May 2005 -- 11 
years ago.

RHEL5 uses gcc-4.1 and it is now 9 years old.
