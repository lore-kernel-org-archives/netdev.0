From: "Eric Van Hensbergen" <ericvh@gmail.com>
Subject: Re: net/9p/mux.c: use-after-free
Date: Wed, 25 Jul 2007 14:45:38 -0500
Message-ID: <a4e6962a0707251245i642eaf90jc7ccc30870958fa3@mail.gmail.com>
References: <20070723012014.GV26212@stusta.de>
	 <a4e6962a0707251143ie0b0ce8s7d4a9078fed7eb26@mail.gmail.com>
	 <f158dc670707251213i65501f9eh6d35a8712583cd90@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Adrian Bunk" <bunk@stusta.de>,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Latchesar Ionkov" <lucho@ionkov.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:34419 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754890AbXGYTpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 15:45:39 -0400
Received: by wa-out-1112.google.com with SMTP id v27so327696wah
        for <netdev@vger.kernel.org>; Wed, 25 Jul 2007 12:45:39 -0700 (PDT)
In-Reply-To: <f158dc670707251213i65501f9eh6d35a8712583cd90@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/25/07, Latchesar Ionkov <lucho@ionkov.net> wrote:
> Yep, it's a leak.
>

Okay, I'll roll that into the patch as well.

           -eric
