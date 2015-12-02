From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 0/3] vxlan: IPv6 fill_metadata_dst support
Date: Wed, 2 Dec 2015 15:02:22 -0800
Message-ID: <CALnjE+qJNyUESRia0WYGQFVdq0DVO3g92AOmWGeA-qJimVBDLw@mail.gmail.com>
References: <cover.1449079592.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:38143 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758425AbbLBXCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 18:02:23 -0500
Received: by igbxm8 with SMTP id xm8so44358166igb.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 15:02:22 -0800 (PST)
In-Reply-To: <cover.1449079592.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 2, 2015 at 10:12 AM, Jiri Benc <jbenc@redhat.com> wrote:
> This adds IPv6 support to ndo_fill_metadata_dst in vxlan together with
> restructuring to avoid duplicate code.
>

We need the ndo_fill_metadata_dst  IPv6 support in net branch, since
OVS IPv6 tunnel support is there already. Is there reason you targeted
this patch series for net-next?
