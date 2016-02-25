From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next v2 00/15][pull request] 1GbE Intel Wired LAN Driver
 Updates 2016-02-24
Date: Thu, 25 Feb 2016 09:45:28 +0200
Message-ID: <CAJ3xEMivnEF=xxvp32_UaE2j5v5x8qeO=5of0y4GZOmAe96Hcw@mail.gmail.com>
References: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>, john.ronciak@intel.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34535 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758745AbcBYHp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 02:45:29 -0500
Received: by mail-io0-f174.google.com with SMTP id 9so74567137iom.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 23:45:29 -0800 (PST)
In-Reply-To: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 25, 2016 at 4:14 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> v2: Dropped patches 6-10 in the original series.  Patch 6-7 added support
>     for character device for AVB and based on community feedback, we do not
>     want to do this.  Patches 8-10 provided fixes to the problematic code
>     added in patches 6 & 7.  So all of them must go!

Jeff,

Did you had special reason not to squash patches 8-10 into 6-7 in the
1st place?

Or.
