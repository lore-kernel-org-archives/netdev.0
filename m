From: Ani Sinha <ani@arista.com>
Subject: Re: list of all network namespaces
Date: Thu, 17 Sep 2015 10:39:57 -0700
Message-ID: <CAOxq_8OTR2neJhDU4BOubWcc7Qd=j9T3jg4ESv-ojXqj+xxYxQ@mail.gmail.com>
References: <CAOxq_8Noj5oxPY5BEsWL6u4h_AD+oXYS+JCRGES_gmMQKd0rOQ@mail.gmail.com>
 <55FA0F4A.3010105@hp.com> <9B0331B6EBBD0E4684FBFAEDA55776F919440808@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rosen, Rami" <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38304 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbbIQRkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 13:40:18 -0400
Received: by igxx6 with SMTP id x6so523759igx.1
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 10:40:17 -0700 (PDT)
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F919440808@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 2:51 AM, Rosen, Rami <rami.rosen@intel.com> wrote:

> Network namespaces which were created by other ways (like userspace applications
> using the clone() system call) will *not* be reflected by neither of them.

Will there be any interest if I cook up a kernel patch that lists all
network namespaces through /proc?
