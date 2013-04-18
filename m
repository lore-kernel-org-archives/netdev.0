From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV probes
Date: Thu, 18 Apr 2013 12:25:59 -0600
Message-ID: <CAErSpo71mvwwW2LheUcZ3giXke_qNWP_NeV=2Fhy147Z=pYOZQ@mail.gmail.com>
References: <20130411190408.GM17641@mtj.dyndns.org> <20130411191717.GB25515@redhat.com>
 <20130411192005.GN17641@mtj.dyndns.org> <20130411203053.GC25515@redhat.com>
 <20130411204104.GC11956@mtj.dyndns.org> <516AA80F.7040505@mellanox.com>
 <20130414134339.GA3050@htj.dyndns.org> <20130418083347.GA16526@redhat.com>
 <517007F0.4060000@mellanox.com> <20130418135458.GC20862@redhat.com> <20130418181930.GF9897@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:48498 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932262Ab3DRS0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 14:26:21 -0400
Received: by mail-ob0-f179.google.com with SMTP id x4so891580obh.38
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 11:26:20 -0700 (PDT)
In-Reply-To: <20130418181930.GF9897@mtj.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 18, 2013 at 12:19 PM, Tejun Heo <tj@kernel.org> wrote:
> On Thu, Apr 18, 2013 at 04:54:58PM +0300, Michael S. Tsirkin wrote:
>> Tejun, what do you say my patch is used for 3.9,
>> and we can revisit for 3.10.
>> The release is almost here.
>> If yes please send your Ack.
>
> Yeap, let's do that.
>
> Acked-by: Tejun Heo <tj@kernel.org>

Michael, can you post a new version with Tejun's ack?  IIRC, this was
in drivers/pci, but I haven't been following this and am not sure
exactly what you want applied.  Thanks.

Bjorn
