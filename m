From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net] ipv4: update comment to document GSO fragmentation
 cases.
Date: Fri, 4 Nov 2016 23:02:08 +0200
Message-ID: <20161104230208.4eaa7346@halley>
References: <1478276558-10974-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lance Richardson <lrichard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34742 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932580AbcKDVCM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 17:02:12 -0400
Received: by mail-wm0-f66.google.com with SMTP id p190so5670867wmp.1
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 14:02:11 -0700 (PDT)
In-Reply-To: <1478276558-10974-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri,  4 Nov 2016 12:22:38 -0400 Lance Richardson <lrichard@redhat.com> wrote:
> This is a follow-up to commit eb96202f1e34 ("ipv4: allow local
> fragmentation in ip_finish_output_gso()"), updating the comment
> documenting cases in which fragmentation is needed for egress
> GSO packets.
> 
> Suggested-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Signed-off-by: Lance Richardson <lrichard@redhat.com>

Thanks Lance.

Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
