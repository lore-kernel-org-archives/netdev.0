From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC iproute2] Add VF link state control
Date: Wed, 8 May 2013 09:17:53 -0700
Message-ID: <20130508091753.0be79e6c@nehalam.linuxnetplumber.net>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>
	<1368020717-22194-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ronye@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:34333 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755326Ab3EHQR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 12:17:57 -0400
Received: by mail-pb0-f52.google.com with SMTP id xa7so1326678pbc.39
        for <netdev@vger.kernel.org>; Wed, 08 May 2013 09:17:57 -0700 (PDT)
In-Reply-To: <1368020717-22194-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  8 May 2013 16:45:17 +0300
Or Gerlitz <ogerlitz@mellanox.com> wrote:

> From: Rony Efraim <ronye@mellanox.com>
> 
> Add link state per VF command
> 
> Signed-off-by: Rony Efraim <ronye@mellanox.com>

Isn't this redundant with OPERSTATE and LOWER_DOWN?
