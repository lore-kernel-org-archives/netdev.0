From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v2 1/2] vxlan: move IPv6 outpute route calculation to
 a function
Date: Fri, 4 Dec 2015 10:47:38 -0800
Message-ID: <CALnjE+q4iXisPViATSydC+P+gbhECWwrPsqngNU1y3yb2Ke7bQ@mail.gmail.com>
References: <cover.1449139112.git.jbenc@redhat.com>
	<7307ccd90b85595e59a31e15cad7bc6187c43fb0.1449139112.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37584 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbbLDSrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 13:47:39 -0500
Received: by igcto18 with SMTP id to18so42483016igc.0
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 10:47:38 -0800 (PST)
In-Reply-To: <7307ccd90b85595e59a31e15cad7bc6187c43fb0.1449139112.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 3, 2015 at 2:41 AM, Jiri Benc <jbenc@redhat.com> wrote:
> Will be used also for ndo_fill_metadata_dst.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Looks good.

Acked-by: Pravin B Shelar <pshelar@nicira.com>
