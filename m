From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 0/3] vxlan: IPv6 fill_metadata_dst support
Date: Thu, 3 Dec 2015 09:44:25 +0100
Message-ID: <20151203094425.4f0fb3bb@griffin>
References: <cover.1449079592.git.jbenc@redhat.com>
	<CALnjE+qJNyUESRia0WYGQFVdq0DVO3g92AOmWGeA-qJimVBDLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49200 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758943AbbLCIo2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 03:44:28 -0500
In-Reply-To: <CALnjE+qJNyUESRia0WYGQFVdq0DVO3g92AOmWGeA-qJimVBDLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Dec 2015 15:02:22 -0800, Pravin Shelar wrote:
> We need the ndo_fill_metadata_dst  IPv6 support in net branch, since
> OVS IPv6 tunnel support is there already. Is there reason you targeted
> this patch series for net-next?

I guess you're right.

I need to resubmit anyway (seems I overlooked a warning when building
without IPv6), I'll submit patches 2 and 3 for net and patch 1 for
net-next (since it's a cleanup).

 Jiri

-- 
Jiri Benc
