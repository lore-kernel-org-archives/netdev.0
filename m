From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/3] myri10ge: LRO to GRO conversion
Date: Wed, 14 Nov 2012 06:27:28 -0800
Message-ID: <1352903248.4497.4.camel@edumazet-glaptop>
References: <50A39747.3030207@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:62707 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932723Ab2KNO1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 09:27:31 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so637181iea.19
        for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 06:27:31 -0800 (PST)
In-Reply-To: <50A39747.3030207@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-14 at 08:06 -0500, Andrew Gallatin wrote:
> Hi,
> 
> The following patchset converts myri10ge from using the old inet_lro
> interface to GRO.

Very nice work, it seems INET_LRO could die eventually ;)
