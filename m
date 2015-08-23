From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH, net-next] r8169: Remove unfounded interrupts
Date: Sun, 23 Aug 2015 09:44:57 -0700
Message-ID: <20150823094457.4bc153c5@urahara>
References: <1440346710-2028-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corcodel Marian <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33024 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbbHWQo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 12:44:59 -0400
Received: by pacti10 with SMTP id ti10so5305443pac.0
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 09:44:59 -0700 (PDT)
In-Reply-To: <1440346710-2028-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Aug 2015 19:18:30 +0300
Corcodel Marian <corcodel.marian@gmail.com> wrote:

> Remove unfounded interrupts which is not on RTL 8101 series.
> 
> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

Kernel style standards precludes use of C++ style comments.

Also, it is is considered best practice to delete incorrect or
dead code rather than littering the source with dead snippets.
