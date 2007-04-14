From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: {Spam?} [PATCH] NET: Remove obsolete traffic shaper code.
Date: Sun, 15 Apr 2007 11:46:56 +1200
Message-ID: <5640c7e00704141646k44334de9g99dc509bf96bac5f@mail.gmail.com>
References: <Pine.LNX.4.64.0704141925310.22138@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Robert P. J. Day" <rpjday@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.237]:23082 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890AbXDNXq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2007 19:46:57 -0400
Received: by nz-out-0506.google.com with SMTP id s1so1015625nze
        for <netdev@vger.kernel.org>; Sat, 14 Apr 2007 16:46:56 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0704141925310.22138@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/15/07, Robert P. J. Day <rpjday@mindspring.com> wrote:
>
> Remove the obsolete code for the traffic shaper.
>
> Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>
>
Apart from the merits of removing this which I can't comment on, I
thought the usual procedure was to place a removal in
Documentation/feature-removal-schedule.txt to notify people of what is
going to be removed. Then wait the period you determine there and then
remove.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
