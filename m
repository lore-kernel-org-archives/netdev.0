From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next v3 0/7] vmxnet3: upgrade to version 3
Date: Tue, 14 Jun 2016 08:52:25 +0300
Message-ID: <CAJ3xEMjtTUXZKLF8seGi+_vQRzw1E1JQhCLtZrBps4Lq=NRfCA@mail.gmail.com>
References: <1465869007-10822-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	pv-drivers@vmware.com
To: Shrikrishna Khare <skhare@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35566 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbcFNFw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 01:52:26 -0400
In-Reply-To: <1465869007-10822-1-git-send-email-skhare@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2016 at 4:50 AM, Shrikrishna Khare <skhare@vmware.com> wrote:
> This patchset upgrades vmxnet3 to version 3.

Except for one patch, all the rest lack change-log, which makes it
somehow needlessly harder to review and maintain

> Shrikrishna Khare (7):
>   vmxnet3: prepare for version 3 changes
>   vmxnet3: introduce generic command interface to configure the device
>   vmxnet3: allow variable length transmit data ring buffer
>   vmxnet3: add receive data ring support
>   vmxnet3: add support for get_coalesce, set_coalesce ethtool operations
>   vmxnet3: introduce command to register memory region
>   vmxnet3: update to version 3
