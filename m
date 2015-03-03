From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next v2 11/17] i40e/i40evf: Add missing packet types for
 VXLAN encapsulated packet types
Date: Tue, 3 Mar 2015 12:53:48 +0200
Message-ID: <CAJ3xEMiuFK+LhHh=OXHO6VuHfXBvGoX4FrOiN67+cb=sirO4Eg@mail.gmail.com>
References: <1425375864-25117-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1425375864-25117-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:41059 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbbCCKxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 05:53:49 -0500
Received: by igal13 with SMTP id l13so25733740iga.0
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 02:53:48 -0800 (PST)
In-Reply-To: <1425375864-25117-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 3, 2015 at 11:44 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Anjali Singhai Jain <anjali.singhai@intel.com>
> We were missing a few packet types for VXLAN offload. This patch fixes
> that.

So you allow your VFs to use VXLAN offloads? what's use case does it
serve today?
