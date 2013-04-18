From: Jesse Gross <jesse@nicira.com>
Subject: Re: [GIT net] Open vSwitch
Date: Wed, 17 Apr 2013 19:31:41 -0700
Message-ID: <CAEP_g=9+YqhrpyCMn=b583iT6Kt+ZTWfRVJd0Kdb4bzjqcPkPQ@mail.gmail.com>
References: <1366143449-8605-1-git-send-email-jesse@nicira.com> <20130416.165302.1176077619833617294.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:56455 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S964932Ab3DRCcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 22:32:03 -0400
Received: by mail-ob0-f197.google.com with SMTP id eh20so5326729obb.0
        for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 19:32:01 -0700 (PDT)
In-Reply-To: <20130416.165302.1176077619833617294.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 16, 2013 at 1:53 PM, David Miller <davem@davemloft.net> wrote:
> From: Jesse Gross <jesse@nicira.com>
> Date: Tue, 16 Apr 2013 13:17:27 -0700
>
>> Two small bug fixes for net/3.9 including the issue previously
>> discussed where allocation of netlink notifications can fail after
>> changes have been committed.
>
> Looks good, pulled, thanks!

Sorry, but can you check whether this was pulled correctly? I'm not
seeing it in your net tree.
