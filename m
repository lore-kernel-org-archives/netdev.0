From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] Enable use of extra debugging information
Date: Mon, 27 Jun 2016 10:52:46 -0700
Message-ID: <20160627105246.5297368b@xeon-e3>
References: <1466551629-7921-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35328 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbcF0Rwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 13:52:32 -0400
Received: by mail-pa0-f52.google.com with SMTP id hl6so61019037pac.2
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 10:52:32 -0700 (PDT)
In-Reply-To: <1466551629-7921-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2016 16:27:09 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> Add -g flag to builds if DEBUG parameter is set. Improves
> debugging with gdb.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

I would rather not put this in the upstream repo.
Developers are free to modify flags as they see fit when debugging.
