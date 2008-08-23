From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [PATCH] tcp: fix tcp header size miscalculation when window scale is unused
Date: Sat, 23 Aug 2008 10:20:38 -0700
Message-ID: <396556a20808231020i699dd8au70735abf15c4e71@mail.gmail.com>
References: <C2868EA2-EAC8-48F4-8CA5-01B7437FD72D@emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Philip Love" <love_phil@emc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:45550 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629AbYHWRUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 13:20:39 -0400
Received: by rv-out-0506.google.com with SMTP id k40so969699rvb.1
        for <netdev@vger.kernel.org>; Sat, 23 Aug 2008 10:20:38 -0700 (PDT)
In-Reply-To: <C2868EA2-EAC8-48F4-8CA5-01B7437FD72D@emc.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 23, 2008 at 10:18 AM, Philip Love <love_phil@emc.com> wrote:
> tcp: fix tcp header size miscalculation when window scale is unused

Reviewed-by: Adam Langley <agl@imperialviolet.org>



AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
