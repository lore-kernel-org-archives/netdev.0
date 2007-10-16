From: jamal <hadi@cyberus.ca>
Subject: Re: Resend: [IPROUTE2 PATCH] Interface group as new ip link option
Date: Tue, 16 Oct 2007 06:45:16 -0400
Message-ID: <1192531516.4480.33.camel@localhost>
References: <ifgroup.20071015.1192520046.panther@balabit.hu>
	 <a6713ba13c49b7fa20073d8abf1862480c2799e0.1192457385.git.panther@balabit.hu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.234]:43616 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755162AbXJPKpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 06:45:46 -0400
Received: by nz-out-0506.google.com with SMTP id s18so1181741nze
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 03:45:45 -0700 (PDT)
In-Reply-To: <a6713ba13c49b7fa20073d8abf1862480c2799e0.1192457385.git.panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-16-10 at 11:03 +0200, Laszlo Attila Toth wrote:
> Interfaces can be grouped and each group has an unique positive integer ID.
> It can be set via ip link.

Feature request: Can you also implement a get operation. Perhaps
something that returns from the kernel a list of ifindices when one
passes a group to it?

BTW, does it make sense to have one interface in multiple groups?

cheers,
jamal

