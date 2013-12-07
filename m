From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next 01/14] i40e: separate TSYNVALID and TSYNINDX fields in
 Rx descriptor
Date: Sat, 7 Dec 2013 23:33:10 +0200
Message-ID: <CAJZOPZKXASf832Q7r+Sz_QU=nAFZVtQEa18etH97Xb-ECOnLag@mail.gmail.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1386382643-29055-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:61488 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759094Ab3LGVdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 16:33:11 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so3048534pbb.18
        for <netdev@vger.kernel.org>; Sat, 07 Dec 2013 13:33:10 -0800 (PST)
In-Reply-To: <1386382643-29055-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 7, 2013 at 4:17 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Jacob Keller <jacob.e.keller@intel.com>
>
> In order to get 1588 to work correctly the defines need a bit
> of a tweak.
>
> Change-Id: Ie50ce2a18e1593441f1560411e5a4f51c6d48aaa

Hi Jeff, we also use this token with out internal gerrit system but
make sure to strip that before sending upstream, are we OK for
upstream commit to carry such tokens from the vendors systems?

Or.


> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
