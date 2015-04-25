From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 3/6] ipv6: netfilter: remove unnecessary braces
Date: Sat, 25 Apr 2015 10:01:05 -0700
Message-ID: <1429981265.32250.25.camel@perches.com>
References: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
	 <1429954020-11763-4-git-send-email-ipm@chirality.org.uk>
	 <1429977542.32250.12.camel@perches.com>
	 <553BC6B2.5080807@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ian Morris <ipm@chirality.org.uk>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0122.hostedemail.com ([216.40.44.122]:46855 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965568AbbDYRBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 13:01:09 -0400
In-Reply-To: <553BC6B2.5080807@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-04-25 at 19:54 +0300, Sergei Shtylyov wrote:
>     Parens around the *return* expression are not necessary. :-)

Yeah, what Sergei said...
