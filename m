From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 0/4]
Date: Mon, 3 Mar 2014 13:15:40 -0800
Message-ID: <CAL3LdT4MgN1EQWwmuB7EyP4jLvFuf6sEDgF47hhjU7b=dx0wyA@mail.gmail.com>
References: <1393631338-18847-1-git-send-email-aaron.f.brown@intel.com>
	<20140302.191906.37467334104875774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Aaron Brown <aaron.f.brown@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:44094 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754255AbaCCVPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 16:15:40 -0500
Received: by mail-ob0-f176.google.com with SMTP id wp18so5667371obc.7
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2014 13:15:40 -0800 (PST)
In-Reply-To: <20140302.191906.37467334104875774.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 2, 2014 at 4:19 PM, David Miller <davem@davemloft.net> wrote:
> From: Aaron Brown <aaron.f.brown@intel.com>
> Date: Fri, 28 Feb 2014 15:48:54 -0800
>
>> Mark updates ixgbe for LER / adapter removal.  He restores the HW
>> address in the recovery path so the device is not perpetually removed,
>> fixes up some removed state ethtool results and adds checks related to
>> config space access.
>>
>> Jacob adds support for the new SIOCGHWTSTAMP ioctl.
>
> [ Note, empty subject ]

Don't worry, Aaron will get 40 lashings for the empty subject. :-)
By the way, I am back from sabbatical now.
