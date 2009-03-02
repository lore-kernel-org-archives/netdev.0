From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH] wimax: replace uses of __constant_{endian}
Date: Sun, 1 Mar 2009 16:07:58 -0800
Message-ID: <200903011607.58333.inaky@linux.intel.com>
References: <1235900574-15319-1-git-send-email-inaky@linux.intel.com> <1235900574-15319-7-git-send-email-inaky@linux.intel.com> <1235934418.5627.0.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, netdev@vger.kernel.org
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:30640 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751201AbZCBAIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 19:08:09 -0500
In-Reply-To: <1235934418.5627.0.camel@brick>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 01 March 2009, Harvey Harrison wrote:
> On Sun, 2009-03-01 at 01:42 -0800, Inaky Perez-Gonzalez wrote:
> > From: Harvey Harrison <harvey.harrison@gmail.com>
> >
> > Base versions handle constant folding now.
> >
> > Edited by Inaky to fix conflicts due to changes in netdev.c
> >
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> > Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
> > ---
>
> I'm not sure the description matches the patch...or the rest of the
> patch is missing.

This is a conflict fix -- yours (the original) is still in the tree, (way) 
before this series. 

However, some of the code merged in with my fixes conflicted with your 
edits, so only those are changed to reflect the new code (hence the 
"Edited" line).

Hope this clarifies

-- 
Inaky
