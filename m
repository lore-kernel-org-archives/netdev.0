From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: mlx4: "failed to allocate default counter port 1"
Date: Wed, 1 Jul 2015 23:38:24 +0300
Message-ID: <CAJ3xEMhWMAtWhw5Xj+3Pj40FAOSpHGJ3ayGn7WsoHJJEuMZiVA@mail.gmail.com>
References: <alpine.LFD.2.11.1506301229520.1799@denkbrett>
	<5592913C.3000207@mellanox.com>
	<alpine.LFD.2.11.1506301520180.1799@denkbrett>
	<55929F2D.9050805@mellanox.com>
	<alpine.LFD.2.11.1506301615100.1799@denkbrett>
	<5593E88F.10006@mellanox.com>
	<alpine.LFD.2.11.1507011554060.1691@denkbrett>
	<alpine.LFD.2.11.1507011616560.1691@denkbrett>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Sebastian Ott <sebott@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:34100 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932AbbGAUiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 16:38:25 -0400
Received: by obbkm3 with SMTP id km3so36300358obb.1
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 13:38:25 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1507011616560.1691@denkbrett>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 1, 2015 at 5:18 PM, Sebastian Ott <sebott@linux.vnet.ibm.com> wrote:
> OK, using this patch it worked:

yep, I forgot to recap err to zero.

By "it worked" you mean the VF is live and kicking, all functionality
you had before the 4.2 merge window is back again?
