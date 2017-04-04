From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] man: fix man page warnings
Date: Tue, 4 Apr 2017 14:47:06 -0700
Message-ID: <20170404144706.7a55558f@xeon-e3>
References: <20170326191114.3756-1-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexander Alemayhu <alexander@alemayhu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:32821 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753656AbdDDVrI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 17:47:08 -0400
Received: by mail-pf0-f169.google.com with SMTP id s16so24227081pfs.0
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 14:47:08 -0700 (PDT)
In-Reply-To: <20170326191114.3756-1-alexander@alemayhu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 26 Mar 2017 21:11:14 +0200
Alexander Alemayhu <alexander@alemayhu.com> wrote:

> While generating PDFs from the man pages, I saw the warning below from
> several files. Compared the tc-matchall.8 with bridge.8 and used .RI
> instead of .R. It should have no effect on the man page rendering.
> 
>     `R' is a string (producing the registered sign), not a macro.
> 
> Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>

Applied
