From: Jeremiah Mahler <jmmahler@gmail.com>
Subject: Re: [PATCH V2] Fix misspelling of defrag in ip-l2tp.8
Date: Wed, 25 Feb 2015 14:43:59 -0800
Message-ID: <20150225224359.GA13975@hudson.localdomain>
References: <20150225185942.GA22050@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, James Chapman <jchapman@katalix.com>
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36215 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752953AbbBYWoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 17:44:03 -0500
Received: by pabkq14 with SMTP id kq14so8758885pab.3
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 14:44:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150225185942.GA22050@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennart,

On Wed, Feb 25, 2015 at 01:59:42PM -0500, Lennart Sorensen wrote:
> Somehow defrag was spelled degrag everywhere it occoured in the ip-l2tp
                                                  ^^^^^^^^
Your patch to fix spelling errors has a spelling error in the log
message ;-)

> man page.  nf_degrag_ipv4 seemed like an odd name for the module and
> couldn't be located, so better fix the man page.
> 
> Signed-off-by: Len Sorensen <lsorense@csclub.uwaterloo.ca>
> ---
[...]

-- 
- Jeremiah Mahler
