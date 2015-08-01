From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] bridge fdb: add 'use' option to set NTF_USE
 flag in fdb add requests
Date: Fri, 31 Jul 2015 18:11:59 -0700
Message-ID: <20150731181159.2ffc00e4@urahara>
References: <1438292222-45993-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: --to=stephen@networkplumber.org, netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33187 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbbHABLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 21:11:51 -0400
Received: by pdbnt7 with SMTP id nt7so50328382pdb.0
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 18:11:50 -0700 (PDT)
In-Reply-To: <1438292222-45993-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Jul 2015 14:37:02 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This is similar to command options corresponding to other NTF_* flags
> already exposed to the user space (examples self/master).
> 
> Also updates bridge man page (The man page patch also includes
> a fix to the 'self' entry and documents 'master' for fdb entries)
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied thanks.
