From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 01/10] tc: red, gred: Rename overloaded
 variable wlog
Date: Thu, 21 May 2015 14:29:52 -0700
Message-ID: <20150521142952.62aa0400@urahara>
References: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
	<1431963314-56420-2-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33729 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756311AbbEUV3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 17:29:50 -0400
Received: by padbw4 with SMTP id bw4so318638pad.0
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 14:29:49 -0700 (PDT)
In-Reply-To: <1431963314-56420-2-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 May 2015 11:35:05 -0400
David Ward <david.ward@ll.mit.edu> wrote:

> It is used when parsing three different parameters, only one of
> which is Wlog. Change the name to make the code less confusing.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>


All applied, and I went ahead and fixed a couple of old style issues in RED/GRED
code as well.
