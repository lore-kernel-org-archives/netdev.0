From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/2] vxlan: group address requires net device
Date: Tue, 20 Sep 2016 09:47:50 -0700
Message-ID: <20160920094750.118fa8ca@xeon-e3>
References: <cover.1473067954.git.jbenc@redhat.com>
        <339db8bf7d0b0bdc9dc69209f4d1d00d45f4132d.1473067954.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33662 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754132AbcITQrk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:47:40 -0400
Received: by mail-pf0-f169.google.com with SMTP id 21so9177235pfy.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 09:47:40 -0700 (PDT)
In-Reply-To: <339db8bf7d0b0bdc9dc69209f4d1d00d45f4132d.1473067954.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  5 Sep 2016 11:35:28 +0200
Jiri Benc <jbenc@redhat.com> wrote:

> This is now enforced in the kernel, check also in iproute to get a better
> error message.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied
